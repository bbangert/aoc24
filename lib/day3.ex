defmodule Day3 do
  @doc ~S"""

  Part 1: Parse corrupted text for mul(x, y) instructions, perform the
  multiplication, and add the results together

  ## Examples

      iex> Day3.add_corrupted_mul_instructions("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))")
      161

  """
  def add_corrupted_mul_instructions(raw_input) do
    Regex.scan(~r/mul\(\s*(\d+)\s*,\s*(\d+)\s*\)/, String.trim(raw_input),
      capture: :all_but_first
    )
    |> Enum.map(fn [x, y] -> {String.to_integer(x), String.to_integer(y)} end)
    |> Enum.reduce(0, fn {x, y}, acc -> acc + x * y end)
  end

  @doc ~S"""

  Part 2: Parse corrupted text file, but only add results for mul instructions if they follow a do() instruction

  ## Examples

      iex> Day3.add_corrupted_mul_instructions_with_do("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))")
      48

  """
  def add_corrupted_mul_instructions_with_do(raw_input) do
    instructions =
      Regex.scan(~r/(do\(\)|don\'t\(\)|mul\(\s*(\d+)\s*,\s*(\d+)\s*\))/, String.trim(raw_input),
        capture: :all_but_first
      )

    process(instructions, true, 0)
  end

  defp process([], _, total), do: total
  defp process([["do()"] | rest], _, total), do: process(rest, true, total)
  defp process([["don't()"] | rest], _, total), do: process(rest, false, total)
  defp process([[_, _, _] | rest], false, total), do: process(rest, false, total)

  defp process([[_, x_str, y_str] | rest], true, total) do
    process(rest, true, total + String.to_integer(x_str) * String.to_integer(y_str))
  end
end
