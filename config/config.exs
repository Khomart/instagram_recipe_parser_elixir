# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :recipe_parser,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :recipe_parser, RecipeParserWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: RecipeParserWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: RecipeParser.PubSub,
  live_view: [signing_salt: "qgHzi1SR"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  recipe_parser: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :reason]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :open_api_spex, :cache_adapter, OpenApiSpex.Plug.NoneCache
