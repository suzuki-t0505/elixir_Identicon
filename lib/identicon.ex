defmodule Identicon do
  def hash_input(input) do
    binary =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()
    %Identicon.Image{hex: binary}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = data) do
    %Identicon.Image{data | color: [r, g, b]}
  end

  def build_grid(data) do
    # Enum.chunk_every(data.hex, 3, 3, :discard)
    list =
      Enum.chunk_every(data.hex, 3)
      |> Enum.drop(-1)
      |> Enum.map(&Identicon.mirror_row(&1))
      |> List.flatten()
      |> Enum.with_index()
      %Identicon.Image{data | grid: list}
  end

  def mirror_row(row) do
    [data1, data2, _tail] = row
    row ++ [data2, data1]
  end

  def filter_add_cells(data) do
    filter =
    Enum.filter(data.grid, fn {value, _number} -> rem(value, 2) == 0 end)
    %Identicon.Image{data | grid: filter}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image)do
    pixcel_map =
      Enum.map grid, fn {_code, index} ->
        top_left = {rem(index, 5) * 50, div(index, 5) * 50}
        bottom_right = {rem(index, 5) * 50 + 50, div(index, 5) * 50 + 50}
        {top_left, bottom_right}
      end
      %Identicon.Image{image | pixcel_map: pixcel_map}
  end

  def main do
    name =
      IO.gets("")
      |> String.trim()

    hash_input(name)
      |> pick_color()
      |> build_grid()
      |> filter_add_cells()
      |> build_pixel_map()
      |> build_image(name)
  end

  def build_image(%Identicon.Image{color: color, pixcel_map: pixcel_map}, name) do
    img = :egd.create(250, 250)
    fill = :egd.color({Enum.at(color, 0), Enum.at(color, 1), Enum.at(color, 2)})
    Enum.each pixcel_map, fn {start, stop} ->
      :egd.filledRectangle(img, start, stop, fill)
    end
    :egd.save(:egd.render(img), "#{name}.png")
  end
end
