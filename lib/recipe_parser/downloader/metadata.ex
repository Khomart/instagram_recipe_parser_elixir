defmodule RecipeParser.Downloader.Metadata do
  require Logger

  # Define the Post struct
  defmodule Post do
    defstruct [
      :display_url,
      :media_type,
      :id,
      :video_url,
      :description
    ]
  end

  def fetch_post_metadata(shortcode) do
    query_hash = "2b0673e0dc4580674a88d426fe00ea90"
    variables = %{"shortcode" => shortcode}
    variables_json = Jason.encode!(variables)

    graphql_url = "https://www.instagram.com/graphql/query/"
    params = "?query_hash=#{query_hash}&variables=#{URI.encode(variables_json)}"

    case get_json("#{graphql_url}#{params}") do
      {:ok, response} ->
        parse_metadata(response)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_json(url) do
    case Req.get(url) do
      {:ok, %Req.Response{status: 200, body: body}} -> {:ok, body}
      {:ok, %Req.Response{status: status}} -> {:error, "Failed to fetch data: #{status}"}
      {:error, %Req.HTTPError{reason: reason}} -> {:error, reason}
    end
  end

  defp parse_metadata(%{"data" => %{"shortcode_media" => media}}) do
    posts =
      if length(media["edge_sidecar_to_children"]["edges"]) > 0 do
        for edge <- media["edge_sidecar_to_children"]["edges"] do
          node = edge["node"]

          description =
            if length(media["edge_media_to_caption"]["edges"]) > 0 do
              media["edge_media_to_caption"]["edges"]
              |> hd()
              |> get_in(["node", "text"])
            else
              ""
            end

          %Post{
            display_url: node["display_url"],
            media_type: node["__typename"],
            id: node["id"],
            video_url: node["video_url"],
            description: description
          }
        end
      else
        description =
          if length(media["edge_media_to_caption"]["edges"]) > 0 do
            media["edge_media_to_caption"]["edges"]
            |> hd()
            |> get_in(["node", "text"])
          else
            ""
          end

        [
          %Post{
            display_url: media["display_url"],
            media_type: media["__typename"],
            id: media["id"],
            video_url: media["video_url"],
            description: description
          }
        ]
      end

    {:ok, posts}
  end

  defp parse_metadata(_any) do
    Logger.error("Invalid post metadata")
    :error
  end
end
