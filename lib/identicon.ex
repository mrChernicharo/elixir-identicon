defmodule Identicon do
  def build(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, filename) do
    File.write("data/#{filename}.png", image)
  end

  def draw_image(%Image{pixel_map: pixel_map, color: color}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, finish} ->
      :egd.filledRectangle(image, start, finish, fill)
    end)

    :egd.render(image)
  end

  def build_pixel_map(%Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_value, idx} ->
        horiz = rem(idx, 5) * 50
        vert = div(idx, 5) * 50

        top_left = {horiz, vert}
        bottom_right = {horiz + 50, vert + 50}

        {top_left, bottom_right}
      end)

    %Image{image | pixel_map: pixel_map}
  end

  def filter_odd(%Image{grid: grid} = image) do
    filtered_grid = Enum.filter(grid, fn {value, _idx} -> rem(value, 2) == 0 end)
    %Image{image | grid: filtered_grid}
  end

  def build_grid(%Image{hex: hex, color: _color} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Image{image | grid: grid}
  end

  defp mirror_row(row) do
    [first, second | _tail] = row

    row ++ [second, first]
  end

  def pick_color(image) do
    %Image{hex: [r, g, b | _tail]} = image
    %Image{image | color: {r, g, b}}
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Image{hex: hex}
  end
end
