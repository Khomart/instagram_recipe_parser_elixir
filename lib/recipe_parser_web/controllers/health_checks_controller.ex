defmodule RecipeParserWeb.HealthChecksController do
  use RecipeParserWeb, :controller

  def ping(conn, _options) do
    json(conn, :pong)
  end
end
