defmodule Day8 do
  @doc ~S"""

  ## Examples

      iex> Day8.part1("............\n........0...\n.....0......\n.......0....\n....0.......\n......A.....\n............\n............\n........A...\n.........A..\n............\n............\n")
      14
  """
  def part1(input) do
    input
    |> parse_input()
    |> then(&find_antinodes/1)
    |> then(&unique_antinodes/1)
    |> Enum.count()
  end

  @doc ~S"""

  ## Examples

      iex> Day8.part2("............\n........0...\n.....0......\n.......0....\n....0.......\n......A.....\n............\n............\n........A...\n.........A..\n............\n............\n")
      34
  """
  def part2(input) do
    input
    |> parse_input()
    |> then(&find_antinodes(&1, :resonate))
    |> then(&unique_antinodes/1)
    |> Enum.count()
  end

  def unique_antinodes(map) do
    map.antinodes
    |> Enum.flat_map(fn {_, antinodes} -> MapSet.to_list(antinodes) end)
    |> MapSet.new()
  end

  def find_antinodes(map, resonate \\ :basic) do
    Enum.reduce(map.antennas, map, fn {antenna, coords}, map ->
      coords
      |> Enum.with_index()
      |> Enum.flat_map(fn {coord, index} ->
        find_antenna_antinodes(map, coord, Enum.drop(coords, index + 1), resonate)
      end)
      |> Enum.reduce(map, fn coord, map ->
        put_in(
          map.antinodes,
          Map.update(map.antinodes, antenna, MapSet.new([coord]), &MapSet.put(&1, coord))
        )
      end)
    end)
  end

  def find_antenna_antinodes(map, cur_check, rem_checks, resonate) do
    Enum.flat_map(rem_checks, &pair_antinodes(map, cur_check, &1, resonate))
  end

  def pair_antinodes(map, {x1, y1}, {x2, y2}, :basic) do
    dx = x2 - x1
    dy = y2 - y1
    [{x1 - dx, y1 - dy}, {x2 + dx, y2 + dy}] |> Enum.reject(&outside_bounds?(map, &1))
  end

  def pair_antinodes(map, {x1, y1}, {x2, y2}, :resonate) do
    dx = x2 - x1
    dy = y2 - y1

    pair_resonates(map, {x1, y1}, {dx, dy}, :back) ++
      pair_resonates(map, {x2, y2}, {dx, dy}, :forward) ++ [{x1, y1}, {x2, y2}]
  end

  def pair_resonates(map, {x, y}, {dx, dy}, :back) do
    antinode = {x - dx, y - dy}

    if outside_bounds?(map, antinode) do
      []
    else
      [antinode] ++ pair_resonates(map, antinode, {dx, dy}, :back)
    end
  end

  def pair_resonates(map, {x, y}, {dx, dy}, :forward) do
    antinode = {x + dx, y + dy}

    if outside_bounds?(map, antinode) do
      []
    else
      [antinode] ++ pair_resonates(map, antinode, {dx, dy}, :forward)
    end
  end

  def outside_bounds?(map, {x, y}) do
    x < 0 || x >= map.width || y < 0 || y >= map.height
  end

  defp parse_input(input) do
    raw_map =
      input
      |> String.trim()
      |> String.split("\n")

    map = %{
      :width => Enum.at(raw_map, 0) |> String.length(),
      :height => Enum.count(raw_map),
      :antennas => %{},
      :antinodes => %{}
    }

    raw_map
    |> Enum.with_index()
    |> Enum.reduce(map, fn {row, y}, map ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {cell, x}, map ->
        if cell == "." do
          map
        else
          put_in(
            map.antennas,
            Map.update(map.antennas, cell, MapSet.new([{x, y}]), &MapSet.put(&1, {x, y}))
          )
        end
      end)
    end)
  end
end
