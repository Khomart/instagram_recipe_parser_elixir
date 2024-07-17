defmodule RecipeParserWeb.Router do
  use RecipeParserWeb, :router
  alias OpenApiSpex.Plug.PutApiSpec

  pipeline :api do
    plug PutApiSpec, module: RecipeParserWeb.ApiSpec
    plug :accepts, ["json"]
  end

  scope "/" do
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  scope "/api", RecipeParserWeb do
    pipe_through :api
    get "/ping", HealthChecksController, :ping
    post "/parse", ParsingController, :recipe
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end
end
