defmodule Day4 do
  @doc ~S"""

  Part 1: Parse a crossword puzzle and find all the valid combinations of XMAS

  ## Examples

      iex> Day4.find_xmas_combinations("MMMSXXMASM\nMSAMXMSMSA\nAMXSXMAAMM\nMSAMASMSMX\nXMASAMXAMM\nXXAMMXXAMA\nSMSMSASXSS\nSAXAMASAAA\nMAMMMXMMMM\nMXMXAXMASX\n")
      18

  """
  def find_xmas_combinations(raw_input) do
    rows = parse_input(raw_input)

    row_counts =
      Enum.reduce(rows, 0, fn row, acc ->
        acc + find_xmas_combinations_in_row(row) +
          find_xmas_combinations_in_row(String.reverse(row))
      end)

    column_chunks = Enum.chunk_every(rows, 4, 1, :discard)
    vertical_counts = Enum.map(column_chunks, &find_xmas_in_columns/1) |> Enum.sum()
    diagonal_counts = Enum.map(column_chunks, &find_xmas_in_diagonals/1) |> Enum.sum()

    row_counts + vertical_counts + diagonal_counts
  end

  defp parse_input(raw_input) do
    raw_input
    |> String.trim()
    |> String.split("\n")
  end

  defp find_xmas_combinations_in_row(row) do
    row
    |> String.split(~r/XMAS/)
    |> then(&(Enum.count(&1) - 1))
  end

  defp find_xmas_in_columns(columns) do
    columns
    |> Enum.map(&String.split(&1, "", trim: true))
    |> count_groupings()
  end

  defp find_xmas_in_diagonals(columns) do
    column_chars = Enum.map(columns, &String.split(&1, "", trim: true))
    right_diag = Enum.map(0..3, fn i -> Enum.at(column_chars, i) |> Enum.drop(i) end)

    left_diag =
      Enum.map(0..3, fn i -> Enum.reverse(column_chars) |> Enum.at(i) |> Enum.drop(i) end)

    count_groupings(right_diag) + count_groupings(left_diag)
  end

  defp count_groupings(groups) do
    groups
    |> Enum.zip()
    |> Enum.map(fn letters -> Tuple.to_list(letters) |> List.to_string() end)
    |> Enum.filter(&(&1 == "XMAS" or &1 == "SAMX"))
    |> Enum.count()
  end

  @doc ~S"""

  Part 2: Parse a crossword puzzle and find all combinations of MAS crossing as an X

  ## Examples

      iex> Day4.find_x_mas_combos("MMMSXXMASM\nMSAMXMSMSA\nAMXSXMAAMM\nMSAMASMSMX\nXMASAMXAMM\nXXAMMXXAMA\nSMSMSASXSS\nSAXAMASAAA\nMAMMMXMMMM\nMXMXAXMASX\n")
      9

  """
  def find_x_mas_combos(raw_input) do
    raw_input
    |> parse_input()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&find_x_mas_in_chunk/1)
    |> Enum.sum()
  end

  defp find_x_mas_in_chunk(chunk) do
    [top, middle, bottom] = chunk |> Enum.map(&String.split(&1, "", trim: true))
    middle_last_index = length(middle) - 1

    Enum.zip(0..middle_last_index, middle)
    |> Enum.reduce(0, fn {index, letter}, acc ->
      case letter do
        "A" when index > 0 and index < middle_last_index ->
          left = Enum.at(top, index-1) <> Enum.at(bottom, index+1)
          right = Enum.at(top, index+1) <> Enum.at(bottom, index-1)
          if (left == "MS" or left == "SM") and (right == "MS" or right == "SM") do
            acc + 1
          else
            acc
          end

        _ ->
          acc
      end
    end)
  end
end
