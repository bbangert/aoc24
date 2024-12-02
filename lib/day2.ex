defmodule Day2 do
  @doc ~S"""

  Part 1: Find the number of safe reports

  ## Examples

      iex> Day2.safe_reports("7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9\n")
      2

  """
  def safe_reports(raw_input) do
    raw_input
    |> parse_input()
    |> Enum.filter(&safe_level/1)
    |> Enum.count()
  end

  def parse_input(raw_input) do
    raw_input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, ~r/\s+/) |> Enum.map(&String.to_integer/1) end)
  end

  defp safe_level(level) do
    pairs = Enum.zip(level, Enum.drop(level, 1))

    Enum.all?(pairs, fn {a, b} -> a < b and safe_distance(a, b) end) or
      Enum.all?(pairs, fn {a, b} -> a > b and safe_distance(a, b) end)
  end

  defp safe_distance(a, b) do
    abs(a - b) > 0 and abs(a - b) < 4
  end

  @doc ~S"""

  Part 2: Find the number of safe reports with Problem Dampener

  ## Examples

      iex> Day2.safe_reports_with_dampener("7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9\n")
      4

  """
  def safe_reports_with_dampener(raw_input) do
    raw_input
    |> parse_input()
    |> Enum.filter(&safe_level_with_dampener/1)
    |> Enum.count()
  end

  defp safe_level_with_dampener(level) do
    Enum.any?([level | Enum.map(1..length(level), &List.delete_at(level, &1 - 1))], &safe_level/1)
  end
end
