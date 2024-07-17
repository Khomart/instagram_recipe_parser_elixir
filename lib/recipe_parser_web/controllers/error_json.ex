defmodule RecipeParserWeb.ErrorJSON do
  def render("404.json", _assigns) do
    %{error: "Not Found"}
  end

  def render("500.json", _assigns) do
    %{error: "Internal Server Error"}
  end

  # Add more render functions for other error codes as needed
end
