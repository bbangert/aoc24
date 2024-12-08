defmodule Day8 do
  @doc ~S"""

  ## Examples

      iex> Day8.part1("............\n........0...\n.....0......\n.......0....\n....0.......\n......A.....\n............\n............\n........A...\n.........A..\n............\n............\n")
      14
  """
  def part1(input, resonate \\ :basic) do
    input
    |> parse_input()
    |> then(&find_antinodes(&1, resonate))
    |> Enum.uniq()
    |> Enum.count()
  end

  @doc ~S"""

  ## Examples

      iex> Day8.part2("............\n........0...\n.....0......\n.......0....\n....0.......\n......A.....\n............\n............\n........A...\n.........A..\n............\n............\n")
      34
  """
  def part2(input), do: part1(input, :resonate)

  def find_antinodes(map, resonate \\ :basic) do
    Enum.flat_map(Map.values(map.antennas), fn coords ->
      Enum.flat_map(Enum.with_index(coords), fn {coord, index} ->
        find_antenna_antinodes(map, coord, Enum.drop(coords, index + 1), resonate)
      end)
    end)
  end

  def find_antenna_antinodes(map, cur_check, rem_checks, resonate) do
    Enum.flat_map(rem_checks, &pair_antinodes(map, cur_check, &1, resonate))
  end

  def pair_antinodes(map, a1, a2, :basic) do
    delta = pair_sub(a1).(a2)
    [pair_sub(delta).(a1), pair_add(delta).(a2)] |> Enum.reject(&outside_bounds?(map, &1))
  end

  def pair_antinodes(map, a1, a2, :resonate) do
    delta = pair_sub(a1).(a2)
    pair_resonates(map, a1, pair_sub(delta)) ++ pair_resonates(map, a2, pair_add(delta))
  end

  def pair_sub({dx, dy}), do: fn {x, y} -> {x - dx, y - dy} end
  def pair_add({dx, dy}), do: fn {x, y} -> {x + dx, y + dy} end

  def pair_resonates(map, pos, op) do
    if outside_bounds?(map, pos) do
      []
    else
      [pos] ++ pair_resonates(map, op.(pos), op)
    end
  end

  def outside_bounds?(map, {x, y}), do: x < 0 || x >= map.width || y < 0 || y >= map.height

  defp parse_input(input) do
    raw_map = String.split(String.trim(input), "\n")

    map = %{
      :width => Enum.at(raw_map, 0) |> String.length(),
      :height => Enum.count(raw_map),
      :antennas => %{},
      :antinodes => %{}
    }

    Enum.reduce(Enum.with_index(raw_map), map, fn {row, y}, map ->
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
