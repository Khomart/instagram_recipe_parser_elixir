defmodule RecipeParserWeb.ParsingController do
  use RecipeParserWeb, :controller
  alias RecipeParser.Parser

  def recipe(conn, request) do
    %{"Url" => url} = request

    case Parser.extract(url) do
      {:ok, resp} ->
        json(conn, resp)

      error ->
        conn
        |> put_status(501)
        |> Phoenix.Controller.json(%{error: error})
        |> halt()
    end
  end
end
