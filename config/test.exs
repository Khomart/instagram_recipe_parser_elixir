import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.

config :recipe_parser, RecipeParserWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "S3PpFSZEeHh3sWfDyHzOd9xCiXbgiANN6K1tk1R2aBl5QQ9ULbqOvhHqw1ls2PV8",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :openai,
  api_key: "dummy",
  organization_key: "dummy"
