defmodule RecipeParserWeb.Schemas.RecipeRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "RecipeRequest",
    description: "Recipe Request schema",
    type: :object,
    properties: %{
      url: %Schema{description: "URL with resources to be parsed", type: :string}
    },
    required: [:url],
    example: %{
      "url" => "https://www.instagram.com/abcdx"
    }
  })
end
