defmodule RecipeParserWeb.Router do
  use RecipeParserWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RecipeParserWeb do
    pipe_through :api
    get "/ping", HealthChecksController, :ping
    post "/parse", ParsingController, :recipe
  end
end
