defmodule Day6 do
  @doc ~S"""

  ## Examples

      iex> Day6.part1("....#.....\n.........#\n..........\n..#.......\n.......#..\n..........\n.#..^.....\n........#.\n#.........\n......#...\n")
      41
  """
  def part1(input) do
    input
    |> parse_input()
    |> then(&patrol_map({:ok, &1}))
    |> then(&unique_traversals(elem(&1, 1)))
    |> Enum.count()
  end

  @doc ~S"""

  ## Examples

      iex> Day6.part2("....#.....\n.........#\n..........\n..#.......\n.......#..\n..........\n.#..^.....\n........#.\n#.........\n......#...\n")
      6
  """
  def part2(input) do
    initial_map = parse_input(input)

    initial_map
    |> then(&patrol_map({:ok, &1}))
    |> then(&unique_traversals(elem(&1, 1)))
    |> Task.async_stream(&check_with_obstruction(initial_map, &1))
    |> Enum.reduce(0, fn {:ok, {result, _}}, acc ->
      if result == :looped, do: acc + 1, else: acc
    end)
  end

  def check_with_obstruction(map, {x, y}) do
    if {x, y} == map.guard_pos do
      {:exited, map}
    else
      %{map | :blocked => MapSet.put(map.blocked, {x, y})} |> then(&patrol_map({:ok, &1}))
    end
  end

  def unique_traversals(map) do
    Enum.reduce(map.traversed, MapSet.new(), fn {x, y, _}, acc -> MapSet.put(acc, {x, y}) end)
  end

  def patrol_map({:done, map}), do: {:exited, map}
  def patrol_map({:loop, map}), do: {:looped, map}
  def patrol_map({:ok, map}), do: patrol_map(move_guard(map))

  def move_guard(map) do
    {guard_x, guard_y} = map.guard_pos

    target_cell =
      case map.guard_dir do
        :north -> {guard_x, guard_y - 1}
        :east -> {guard_x + 1, guard_y}
        :south -> {guard_x, guard_y + 1}
        :west -> {guard_x - 1, guard_y}
      end

    case MapSet.member?(map.blocked, target_cell) do
      true -> {:ok, rotate_guard(map)}
      false -> bounds_check(map, target_cell)
    end
  end

  def bounds_check(map, target_cell) do
    if outside_bounds?(map, target_cell) do
      {:done, map}
    else
      loop_check(map, target_cell)
    end
  end

  def loop_check(map, target_cell) do
    guard_loc = Tuple.append(target_cell, map.guard_dir)

    if MapSet.member?(map.traversed, guard_loc) do
      {:loop, map}
    else
      {:ok,
       %{map | :guard_pos => target_cell, :traversed => MapSet.put(map.traversed, guard_loc)}}
    end
  end

  def outside_bounds?(map, {x, y}) do
    x < 0 || x >= map.width || y < 0 || y >= map.height
  end

  def rotate_guard(map) do
    case map.guard_dir do
      :north -> %{map | :guard_dir => :east}
      :east -> %{map | :guard_dir => :south}
      :south -> %{map | :guard_dir => :west}
      :west -> %{map | :guard_dir => :north}
    end
  end

  defp parse_input(input) do
    raw_map =
      input
      |> String.trim()
      |> String.split("\n")

    map = %{
      :width => Enum.at(raw_map, 0) |> String.length(),
      :height => Enum.count(raw_map),
      :blocked => MapSet.new(),
      :traversed => MapSet.new(),
      :guard_pos => {0, 0},
      :guard_dir => :north
    }

    raw_map
    |> Enum.with_index()
    |> Enum.reduce(map, fn {row, y}, map ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {cell, x}, map ->
        case cell do
          "#" -> %{map | :blocked => MapSet.put(map.blocked, {x, y})}
          "^" -> %{map | :guard_pos => {x, y}, :guard_dir => :north}
          "v" -> %{map | :guard_pos => {x, y}, :guard_dir => :south}
          "<" -> %{map | :guard_pos => {x, y}, :guard_dir => :west}
          ">" -> %{map | :guard_pos => {x, y}, :guard_dir => :east}
          _ -> map
        end
      end)
    end)
    |> then(fn map ->
      %{map | :traversed => MapSet.put(map.traversed, Tuple.append(map.guard_pos, map.guard_dir))}
    end)
  end
end
