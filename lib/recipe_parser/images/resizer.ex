defmodule RecipeParser.Resizer do
  @moduledoc """
  A module for resizing and encoding images.
  """

  import Mogrify
  require Base

  def resize_and_encode_image(input_path, max_width, max_height) do
    open(input_path)
    |> resize("#{max_width}x#{max_height}")
    |> save(in_place: true)

    input_path
    |> File.read!()
    |> Base.encode64()
  end
end
