defmodule Day10 do
  @doc ~S"""

  ## Examples

      iex> Day10.part1("89010123\n78121874\n87430965\n96549874\n45678903\n32019012\n01329801\n10456732")
      36
  """
  def part1(input) do
    input
    |> parse_input()
    |> score_trails()
    |> Enum.sum()
  end

  @doc ~S"""

  ## Examples

      iex> Day10.part2("89010123\n78121874\n87430965\n96549874\n45678903\n32019012\n01329801\n10456732")
      81
  """
  def part2(input) do
    input
    |> parse_input()
    |> rate_trails()
    |> Enum.sum()
  end

  def rate_trails(map), do: Enum.map(Map.keys(map.starts), fn pos -> rate_trail(map, pos) end)

  def rate_trail(map, pos), do: score_trail(map, pos, 0) |> Enum.count()

  def score_trails(map), do: Enum.map(Map.keys(map.starts), fn pos -> score_trail(map, pos) end)

  def score_trail(map, pos) do
    score_trail(map, pos, 0)
    |> Enum.uniq()
    |> Enum.count()
  end

  def score_trail(_, pos, 9), do: [pos]

  def score_trail(map, pos, height) do
    next_nodes = find_next_nodes(map, pos, height + 1)

    case length(next_nodes) do
      0 -> []
      _ -> Enum.flat_map(next_nodes, fn node -> score_trail(map, node, height + 1) end)
    end
  end

  def find_next_nodes(map, pos, height) do
    possible_nodes(pos)
    |> Enum.reject(&outside_bounds?(map, &1))
    |> Enum.filter(&valid_height?(map, &1, height))
  end

  def possible_nodes({x, y}), do: [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}]

  def outside_bounds?(map, {x, y}), do: x < 0 || x >= map.width || y < 0 || y >= map.height

  def valid_height?(map, {x, y}, height), do: Map.get(map.coords, {x, y}) == height

  def parse_input(input) do
    raw_input = String.split(String.trim(input), "\n", trim: true)

    map = %{
      :width => Enum.at(raw_input, 0) |> String.length(),
      :height => length(raw_input),
      :coords => Map.new(),
      :starts => Map.new()
    }

    raw_input
    |> Enum.with_index()
    |> Enum.reduce(map, fn {row, y}, m ->
      row
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reduce(m, fn {value, x}, m ->
        put_in(m.coords, Map.put(m.coords, {x, y}, value)) |> update_start({x, y}, value)
      end)
    end)
  end

  def update_start(map, {x, y}, value) do
    case value do
      0 -> put_in(map.starts, Map.put(map.starts, {x, y}, value))
      _ -> map
    end
  end
end
