defmodule RecipeParser.Downloader do
  require Logger

  alias RecipeParser.Downloader.Metadata
  alias RecipeParser.Downloader.Shortcode

  def fetch_post(instagram_url) do
    with {:ok, shortcode} <- Shortcode.extract(instagram_url),
         :ok <- create_download_folder(shortcode),
         {:ok, [_ | _] = posts} <- Metadata.fetch_post_metadata(shortcode) do
      Logger.info("Extracted shortcode: #{shortcode}")
      download_folder = Path.join(["downloads", shortcode])
      save_description(download_folder, hd(posts).description)

      Enum.with_index(posts, fn post, idx ->
        Logger.info("Fetched post metadata: #{inspect(post)}")

        case download_post(download_folder, post, idx) do
          :ok -> :ok
          {:error, exception} ->
            Logger.error("Error downloading post, exception #{exception}")
            :error
        end
      end)

      {:ok, download_folder}
    else
      {:error, reason} ->
        Logger.error("Error: #{reason}")
        :error
    end
  end

  defp create_download_folder(shortcode) do
    download_folder = Path.join(["downloads", shortcode])

    case File.mkdir_p(download_folder) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp save_description(folder, description) when description != "" do
    File.write(Path.join(folder, "description.txt"), description)
  end

  defp save_description(_folder, _description), do: :ok

  defp download_post(folder, post, idx) do
    media_url = if post.media_type == "GraphVideo", do: post.video_url, else: post.display_url
    filename = "#{post.id}_#{idx}"
    mtime = DateTime.utc_now()

    case download_media(folder, filename, media_url, mtime, nil) do
      {:ok, _any} ->
        Logger.info("Media downloaded successfully: #{filename}")
        :ok

      {:error, exception} ->
        {:error, exception}
    end
  end

  defp download_media(folder, filename, url, mtime, filename_suffix) do
    filename = if filename_suffix, do: "#{filename}_#{filename_suffix}", else: filename
    file_extension = get_file_extension(url)
    nominal_filename = Path.join([folder, "#{filename}.#{file_extension}"])

    case File.stat(nominal_filename) do
      {:ok, _} ->
        Logger.info("#{nominal_filename} exists")
        {:ok, false}

      _ ->
        download_and_save_file(folder, filename, url, mtime)
    end
  end

  defp get_file_extension(url) do
    case Regex.run(~r/\.([a-z0-9]+)\?/, url) do
      [_, match] -> match
      _ -> String.slice(url, -3..-1)
    end
  end

  defp download_and_save_file(folder, filename, url, mtime) do
    with {:ok, %Req.Response{body: body, headers: headers}} <- Req.get(url),
         {:ok, final_filename} <- determine_final_filename(folder, filename, headers),
         :ok <- File.write(final_filename, body),
         posix_mtime = DateTime.to_unix(mtime),
         :ok <- File.touch(final_filename, posix_mtime) do
      {:ok, true}
    else
      {:error, exception} -> {:error, exception}
    end
  end

  defp determine_final_filename(folder, filename, headers) do
    content_type_list = Map.get(headers, "content-type", "")
    [content_type | _rest] = content_type_list

    header_extension =
      "." <>
        String.downcase(
          String.split(content_type, "/")
          |> List.last()
          |> String.split(";")
          |> List.first()
        )

    final_filename =
      if header_extension == ".jpeg",
        do: "#{filename}.jpg",
        else: "#{filename}#{header_extension}"

    final_filename = Path.join(folder, final_filename)

    case File.stat(final_filename) do
      {:ok, _} ->
        Logger.info("#{final_filename} exists")
        {:ok, false}

      _ ->
        {:ok, final_filename}
    end
  end
end
