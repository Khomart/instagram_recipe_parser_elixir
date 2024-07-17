defmodule RecipeParser.Processor do
  require Logger

  import FFmpex
  use FFmpex.Options

  alias OpenAI
  alias RecipeParser.Resizer

  # Summarize content using OpenAI API
  def summarize_content(folder_path) do
    case File.ls(folder_path) do
      {:ok, files} ->
        files
        |> Enum.map(&Path.join(folder_path, &1))
        |> Enum.reduce_while("", fn file_path, acc ->
          ext = Path.extname(file_path) |> String.downcase()

          case summarize_file(file_path, ext) do
            {:ok, summary} ->
              {:cont, acc <> summary <> "\n"}

            {:error, reason} ->
              {:halt, {:error, reason}}
          end
        end)
        |> case do
          {:error, reason} ->
            {:error, reason}

          content ->
            OpenAI.chat_completion(
              model: "gpt-4-turbo",
              messages: [
                %{
                  role: "user",
                  content:
                    "Combine the following content into a short recipe instruction. Give short 1-2 sentence description, separate list of ingredients and steps how to prepare the dish. \n\n#{content}"
                }
              ],
              max_tokens: 1000
            )
            |> case do
              {:ok, %{choices: [%{"message" => %{"content" => final_summary}}]}} ->
                {:ok, final_summary}

              {:error, reason} ->
                {:error, "Failed to create recipe instruction: #{reason}"}
            end
        end

      {:error, reason} ->
        {:error, "Failed to read folder: #{reason}"}
    end
  end

  # Analyze text content using the OpenAI API
  defp analyze_text(content) do
    response =
      OpenAI.chat_completion(
        model: "gpt-4-turbo",
        messages: [
          %{
            role: "user",
            content: "Summarize the following content for a recipe instruction:\n\n#{content}"
          }
        ],
        max_tokens: 100
      )

    case response do
      {:ok, %{choices: [%{"message" => %{"content" => summary}}]}} -> {:ok, summary}
      {:error, reason} -> {:error, "Failed to summarize text content: #{reason}"}
    end
  end

  # Analyze image content using the OpenAI API
  defp analyze_image(file_path) do
    case File.read(file_path) do
      {:ok, _img_data} ->
        base64_img = Resizer.resize_and_encode_image(file_path, 800, 800)

        response =
          OpenAI.chat_completion(
            model: "gpt-4-vision-preview",
            messages: [
              %{
                role: "user",
                content: [
                  %{
                    type: "text",
                    text: "Analyze the following image and summarize it as a recipe instruction"
                  },
                  %{type: "image_url", image_url: "data:image/jpeg;base64,#{base64_img}"}
                ]
              }
            ]
          )

        case response do
          {:ok, %{choices: [%{"message" => %{"content" => summary}}]}} -> {:ok, summary}
          {:error, reason} -> {:error, "Failed to analyze image content: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Failed to read image: #{file_path}, reason #{reason}"}
    end
  end

  # Analyze audio content using the OpenAI API
  defp analyze_audio(file_path) do
    response =
      OpenAI.audio_transcription(
        file_path,
        model: "whisper-1",
        prompt: "Analyze the audio content for a recipe instruction"
      )

    case response do
      {:ok, %{text: text}} -> {:ok, text}
      {:error, reason} -> {:error, "Failed to analyze audio content: #{reason}"}
    end
  end

  # Convert video file to audio file using FFmpeg
  defp convert_video_to_audio(video_path, audio_path) do
    command =
      FFmpex.new_command()
      |> add_input_file(video_path)
      |> add_output_file(audio_path)
      |> add_file_option(option_vn())
      |> add_file_option(option_acodec("mp3"))

    case FFmpex.execute(command) do
      {:ok, _any} -> :ok
      {:error, reason} -> {:error, "Failed to convert video to audio: #{reason}"}
    end
  end

  defp summarize_file(file_path, ".txt") do
    with {:ok, content} <- File.read(file_path) do
      analyze_text(content)
    end
  end

  defp summarize_file(file_path, ext) when ext in [".jpg", ".jpeg", ".png"] do
    analyze_image(file_path)
  end

  defp summarize_file(file_path, ext) when ext in [".mp4", ".avi", ".mkv"] do
    audio_path = Path.rootname(file_path) <> ".mp3"

    with :ok <- convert_video_to_audio(file_path, audio_path),
         {:ok, summary} <- analyze_audio(audio_path) do
      {:ok, summary}
    end
  end

  defp summarize_file(_file_path, _ext), do: {:error, :unsupported_file_format}
end
