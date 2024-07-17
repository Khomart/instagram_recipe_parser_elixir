defmodule RecipeParserWeb.ParsingControllerTest do
  use RecipeParserWeb.ConnCase, async: true
  import Mimic

  alias RecipeParser.Parser

  @valid_url "http://valid.url/recipe"
  @invalid_url "http://invalid.url/recipe"

  describe "POST /recipe" do
    test "returns 200 and recipe response for a valid URL", %{conn: conn} do
      recipe_response = "1 cup of sugar, 2 cups of flour"

      expect(Parser, :extract, fn @valid_url -> {:ok, recipe_response} end)

      conn = post(conn, "/api/parse", %{"Url" => @valid_url})
      assert json_response(conn, 200) == %{"response" => recipe_response}
    end

    test "returns 500 and error message for an invalid URL", %{conn: conn} do
      error_response = "Invalid URL"

      expect(Parser, :extract, fn @invalid_url -> {:error, error_response} end)

      conn = post(conn, "/api/parse", %{"Url" => @invalid_url})
      assert json_response(conn, 500) == %{"error" => error_response}
    end
  end
end
