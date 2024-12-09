defmodule Day9 do
  @doc ~S"""

  ## Examples

      iex> Day9.part1("2333133121414131402")
      1928
  """
  def part1(input) do
    input
    |> parse_to_blocks()
    |> defragment()
    |> checksum()
  end

  @doc ~S"""

  ## Examples

      iex> Day9.part2("2333133121414131402")
      2858
  """
  def part2(input) do
    input
    |> parse_to_blocks()
    |> file_defragment()
    |> checksum()
  end

  def checksum(blocks) do
    for index <- 0..(:array.size(blocks) - 1), reduce: 0 do
      acc ->
        case :array.get(index, blocks) do
          "." -> acc
          file_id -> acc + file_id * index
        end
    end
  end

  def file_defragment(blocks) do
    {file_id, start_index, end_index} = find_next_file_chunk(blocks, :array.size(blocks) - 1)
    file_defragment(blocks, file_id, start_index, end_index)
  end

  def file_defragment(blocks, 0, _, _), do: blocks

  def file_defragment(blocks, file_id, start_index, end_index) do
    space_result = find_space_gap(blocks, end_index - start_index + 1)
    blocks = move_file(blocks, file_id, start_index, end_index, space_result)
    {file_id, start_index, end_index} = find_next_file_chunk(blocks, start_index - 1, file_id - 1)
    file_defragment(blocks, file_id, start_index, end_index)
  end

  def move_file(blocks, _, _, _, {:not_found}), do: blocks

  def move_file(blocks, file_id, start_index, end_index, {:ok, gap_start}) do
    if gap_start >= start_index do
      blocks
    else
      for index <- 0..(end_index - start_index), reduce: blocks do
        blocks ->
          :array.set(gap_start + index, file_id, blocks)
          |> then(&:array.set(start_index + index, ".", &1))
      end
    end
  end

  def find_next_file_chunk(blocks, end_at, next_file_id \\ -1) do
    case :array.get(end_at, blocks) do
      "." ->
        find_next_file_chunk(blocks, end_at - 1, next_file_id)

      file_id when next_file_id != -1 and file_id != next_file_id ->
        find_next_file_chunk(blocks, end_at - 1, next_file_id)

      file_id ->
        {file_id, last_digit_begin(blocks, file_id, end_at), end_at}
    end
  end

  def find_space_gap(blocks, size), do: find_space_gap(blocks, size, 0, 0)

  def find_space_gap(blocks, size, index, prev) do
    cond do
      prev == size -> {:ok, index - size}
      index == :array.size(blocks) -> {:not_found}
      :array.get(index, blocks) == "." -> find_space_gap(blocks, size, index + 1, prev + 1)
      true -> find_space_gap(blocks, size, index + 1, 0)
    end
  end

  def first_digit_index(blocks, check) do
    case :array.get(check, blocks) do
      "." -> first_digit_index(blocks, check + 1)
      _ -> check
    end
  end

  def last_digit_begin(blocks, file_id, index) do
    case :array.get(index, blocks) do
      fid when fid == file_id and index == 0 -> 0
      fid when fid == file_id -> last_digit_begin(blocks, file_id, index - 1)
      _ -> index + 1
    end
  end

  def defragment(blocks) do
    free_index = first_free_index(blocks, 0)
    {char, last_index} = last_digit_index(blocks, :array.size(blocks) - 1)
    defragment(blocks, free_index, last_index, char)
  end

  def defragment(blocks, free_index, last_index, _) when free_index >= last_index, do: blocks

  def defragment(blocks, free_index, last_index, char) do
    blocks =
      :array.set(last_index, ".", blocks)
      |> then(&:array.set(free_index, char, &1))

    free_index = first_free_index(blocks, free_index)
    {char, last_index} = last_digit_index(blocks, last_index)

    defragment(blocks, free_index, last_index, char)
  end

  def first_free_index(blocks, check) do
    case :array.get(check, blocks) do
      "." -> check
      _ -> first_free_index(blocks, check + 1)
    end
  end

  def last_digit_index(blocks, check) do
    case :array.get(check, blocks) do
      "." -> last_digit_index(blocks, check - 1)
      char -> {char, check}
    end
  end

  def parse_to_blocks(input) do
    input
    |> String.trim()
    |> String.to_integer()
    |> Integer.digits()
    |> parse_blocks([], 0)
    |> then(&:array.from_list(&1))
  end

  def parse_blocks([], acc, _), do: acc

  def parse_blocks([blocks], acc, id) do
    case blocks do
      0 -> acc
      count -> acc ++ Enum.map(1..count, fn _ -> id end)
    end
  end

  def parse_blocks([blocks, space | rest], acc, id) do
    file_blocks =
      case blocks do
        0 -> []
        count -> Enum.map(1..count, fn _ -> id end)
      end

    space_blocks =
      case space do
        0 -> []
        count -> Enum.map(1..count, fn _ -> "." end)
      end

    parse_blocks(rest, acc ++ file_blocks ++ space_blocks, id + 1)
  end
end
