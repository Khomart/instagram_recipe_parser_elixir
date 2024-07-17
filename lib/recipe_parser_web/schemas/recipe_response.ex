defmodule RecipeParserWeb.Schemas.RecipeResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "RecipeResponse",
    description: "The response of a successful recipe extraction",
    type: :object,
    properties: %{
      response: %Schema{type: :string, description: "The extracted recipe information"}
    },
    required: [:response]
  })
end
