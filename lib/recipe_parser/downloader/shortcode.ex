defmodule RecipeParser.Downloader.Shortcode do
  require Logger

  def extract(instagram_url) do
    %URI{path: path} = URI.parse(instagram_url)
    segments = String.split(path, "/")

    if length(segments) > 2 && Enum.at(segments, 1) == "p" do
      {:ok, Enum.at(segments, 2)}
    else
      Logger.error("invalid Instagram post URL, segments: #{segments}")
      {:error, "invalid Instagram post URL"}
    end
  end
end
