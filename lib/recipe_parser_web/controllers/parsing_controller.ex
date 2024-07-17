defmodule RecipeParserWeb.ParsingController do
  use RecipeParserWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias RecipeParser.Parser
  alias RecipeParserWeb.Schemas.{RecipeRequest, RecipeResponse}

  tags ["parsing"]

  operation :recipe,
    summary: "Extracts recipe information from a given URL",
    request_body: {"User params", "application/json", RecipeRequest},
    responses: [
      ok: {"User response", "application/json", RecipeResponse}
    ]

  def recipe(conn, request) do
    %{"Url" => url} = request

    case Parser.extract(url) do
      {:ok, resp} ->
        json(conn, %{response: resp})

      {:error, error} ->
        dbg(error)
        conn
        |> put_status(500)
        |> Phoenix.Controller.json(%{error: error})
        |> halt()

      error ->
        dbg(error)
        conn
        |> put_status(500)
        |> Phoenix.Controller.json(%{error: error})
        |> halt()
    end
  end
end
