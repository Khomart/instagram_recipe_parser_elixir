defmodule RecipeParserWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :recipe_parser

  plug Plug.Static,
    at: "/swagger",
    from: :phoenix_swagger,
    only: ~w(index.html swagger-ui.js swagger-ui.css)

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug RecipeParserWeb.Router
end
