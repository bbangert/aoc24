defmodule Day1 do
  @doc ~S"""

  Part 1: Compare the difference in the lists

  ## Examples

      iex> Day1.compare_lists("3   4\n4   3\n2   5\n1   3\n3   9\n3   3\n")
      11

  """
  def compare_lists(raw_input) do
    raw_input
    |> split_to_int_lists()
    |> Tuple.to_list()
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip_reduce(0, fn [a, b], acc -> acc + abs(a - b) end)
  end

  defp split_to_int_lists(raw_input) do
    raw_input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, ~r/\s+/) |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.unzip()
  end

  @doc ~S"""

  Part 2: Find similarity scores in the lists

  ## Examples

      iex> Day1.find_similarity_scores("3   4\n4   3\n2   5\n1   3\n3   9\n3   3\n")
      31

  """
  def find_similarity_scores(raw_input) do
    {left, right} = split_to_int_lists(raw_input)

    Enum.reduce(left, 0, fn element, acc ->
      acc + element * Enum.count(right, &(&1 == element))
    end)
  end
end
