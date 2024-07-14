defmodule RecipeParser.Parser do
  require Logger

  alias RecipeParser.Downloader
  alias RecipeParser.Processor

  def extract(url) do
    with :ok <- verify_url(url),
         {:ok, downloaded} <- Downloader.fetch_post(url) do
      Processor.summarize_content(downloaded)
    end
  end

  def verify_url(url) do
    regex = ~r/\.?([^.]*\.com)/

    case Regex.run(regex, url) do
      nil ->
        Logger.error("URL domain mismatch", domain: nil)
        :error

      [_full_match, domain] when domain != "instagram.com" ->
        Logger.error("URL domain mismatch", domain: domain)
        :error

      _ ->
        :ok
    end
  end
end
