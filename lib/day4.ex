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

  def parse_input(raw_input) do
    raw_input
    |> String.trim()
    |> String.split("\n")
  end

  def find_xmas_combinations_in_row(row) do
    row
    |> String.split(~r/XMAS/)
    |> then(&(Enum.count(&1) - 1))
  end

  def find_xmas_in_columns(columns) do
    columns
    |> Enum.map(&String.split(&1, "", trim: true))
    |> count_groupings()
  end

  def find_xmas_in_diagonals(columns) do
    column_chars = Enum.map(columns, &String.split(&1, "", trim: true))
    right_diag = Enum.map(0..3, fn i -> Enum.at(column_chars, i) |> Enum.drop(i) end)
    left_diag = Enum.map(0..3, fn i -> Enum.reverse(column_chars) |> Enum.at(i) |> Enum.drop(i) end)
    count_groupings(right_diag) + count_groupings(left_diag)
  end

  def count_groupings(groups) do
    groups
    |> Enum.zip()
    |> Enum.map(fn letters -> Tuple.to_list(letters) |> List.to_string() end)
    |> Enum.filter(&(&1 == "XMAS" or &1 == "SAMX"))
    |> Enum.count()
  end
end
