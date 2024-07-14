defmodule RecipeParserWeb.HealthChecksJSON do
  def render("ping.json", _assigns) do
    :pong
  end
end
