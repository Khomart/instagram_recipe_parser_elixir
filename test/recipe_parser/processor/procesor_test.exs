defmodule RecipeParser.ProcessorTest do
  use ExUnit.Case, async: true
  import Mimic

  alias RecipeParser.Processor

  setup :verify_on_exit!

  describe "summarize_content/1" do
    test "returns summarized content for valid text files" do
      folder_path = "test1"
      file_path = Path.join(folder_path, "test.txt")
      content = "Sample text content"
      summary = "Summarized text content"

      expect(File, :ls, fn ^folder_path -> {:ok, ["test.txt"]} end)
      expect(File, :read, fn ^file_path -> {:ok, content} end)

      stub(OpenAI, :chat_completion, fn _ ->
        {:ok, %{choices: [%{"message" => %{"content" => summary}}]}}
      end)

      assert Processor.summarize_content(folder_path) == {:ok, summary <> ""}
    end

    test "returns summarized content for valid image files" do
      folder_path = "test2"
      file_path = Path.join(folder_path, "test.jpg")
      summary = "Summarized image content"
      base64_img = "base64encodedimage"

      expect(File, :ls, fn ^folder_path -> {:ok, ["test.jpg"]} end)
      expect(File, :read, fn ^file_path -> {:ok, <<255, 216, 255>>} end)

      expect(RecipeParser.Resizer, :resize_and_encode_image, fn ^file_path, 800, 800 ->
        base64_img
      end)

      stub(OpenAI, :chat_completion, fn _ ->
        {:ok, %{choices: [%{"message" => %{"content" => summary}}]}}
      end)

      assert Processor.summarize_content(folder_path) == {:ok, summary <> ""}
    end

    test "handles errors in summarizing files" do
      folder_path = "test3"
      file_path = Path.join(folder_path, "test.txt")
      error_reason = "File read error"

      expect(File, :ls, fn ^folder_path -> {:ok, ["test.txt"]} end)
      expect(File, :read, fn ^file_path -> {:error, error_reason} end)

      assert Processor.summarize_content(folder_path) == {:error, error_reason}
    end

    test "handles errors in folder reading" do
      folder_path = "test4"
      error_reason = "Folder read error"

      expect(File, :ls, fn ^folder_path -> {:error, error_reason} end)

      assert Processor.summarize_content(folder_path) ==
               {:error, "Failed to read folder: #{error_reason}"}
    end

    test "returns error for unsupported file types" do
      folder_path = "test5"
      file_path = Path.join(folder_path, "test.unsupported")

      expect(File, :ls, fn ^folder_path -> {:ok, ["test.unsupported"]} end)

      assert Processor.summarize_content(folder_path) == {:error, :unsupported_file_format}
    end
  end
end
