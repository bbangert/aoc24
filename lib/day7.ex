defmodule Day7 do
  @doc ~S"""

  ## Examples

      iex> Day7.part1("190: 10 19\n3267: 81 40 27\n83: 17 5\n156: 15 6\n7290: 6 8 6 15\n161011: 16 10 13\n192: 17 8 14\n21037: 9 7 18 13\n292: 11 6 16 20")
      3749
  """
  def part1(input) do
    input
    |> parse_input()
    |> Enum.filter(&can_make_total/1)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  @doc ~S"""

  ## Examples

      iex> Day7.part2("190: 10 19\n3267: 81 40 27\n83: 17 5\n156: 15 6\n7290: 6 8 6 15\n161011: 16 10 13\n192: 17 8 14\n21037: 9 7 18 13\n292: 11 6 16 20")
      11387
  """
  def part2(input) do
    input
    |> parse_input()
    |> Task.async_stream(fn {total, numbers} -> {total, can_make_total({total, numbers}, :use_concat)} end)
    |> Enum.reduce(0, fn {:ok, {value, result}}, acc ->
      if result, do: acc + value, else: acc
    end)
  end

  def can_make_total({total, numbers}, opts \\ :none),
    do: test_total(total, 0, numbers, opts) == :found

  def test_total(total, current, [], _) do
    if current == total do
      :found
    else
      :not_found
    end
  end

  def test_total(total, current, [fst | rest], opts) do
    if current > total do
      :not_found
    else
      case test_total(total, current + fst, rest, opts) do
        :found ->
          :found

        :not_found ->
          case test_total(total, current * fst, rest, opts) do
            :found ->
              :found

            :not_found ->
              if opts == :use_concat do
                test_total(total, concat_numbers(current, fst), rest, opts)
              else
                :not_found
              end
          end
      end
    end
  end

  def concat_numbers(a, b), do: String.to_integer("#{a}#{b}")

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [total, numbers] = String.split(line, ": ")
    {String.to_integer(total), String.split(numbers, " ") |> Enum.map(&String.to_integer/1)}
  end
end
