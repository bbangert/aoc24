defmodule Day5 do
  @doc ~S"""

  Part 1: Parse a list of ordering pairs and then the updates, and sum up the middle
  number of each update that is valid according to the rules.

  ## Examples

    iex> Day5.check_updates("\n47|53\n97|13\n97|61\n97|47\n75|29\n61|13\n75|53\n29|13\n97|29\n53|29\n61|53\n97|53\n61|29\n47|13\n75|47\n97|75\n47|61\n75|61\n47|29\n75|13\n53|13\n\n75,47,61,53,29\n97,61,53,29,13\n75,29,13\n75,97,47,61,53\n61,13,29\n97,13,75,29,47\n")
    143

  """
  def check_updates(raw_input) do
    [rule_chunk, update_chunk] = raw_input |> String.trim() |> String.split(~r"\n\n", trim: true)
    rules = parse_rules(rule_chunk)

    split_and_parse(update_chunk, ~r"\,")
    |> Enum.filter(&valid_update(rules, &1))
    |> Enum.map(&middle_number/1)
    |> Enum.sum()
  end

  defp middle_number(update), do: Enum.at(update, div(Enum.count(update), 2))

  defp parse_rules(rules) do
    rules
    |> split_and_parse(~r"\|")
    |> Enum.reduce(%{}, fn [key, value], acc ->
      Map.put(acc, "#{key}|#{value}", true)
    end)
  end

  defp split_and_parse(input, separator) do
    input
    |> String.split(~r"\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, separator, trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end

  defp valid_update(rules, update) do
    Enum.all?(0..(length(update) - 1), &valid_index(rules, update, &1))
  end

  defp valid_updates(rules, key, values), do: Enum.all?(values, &valid_order(rules, key, &1))

  defp valid_index(rules, update, index) do
    {before, remaining} = Enum.split(update, index)
    Enum.all?(Enum.map(before, &valid_updates(rules, &1, remaining)))
  end

  defp valid_order(rules, a, b), do: Map.has_key?(rules, "#{a}|#{b}")

  @doc ~S"""

  Part 2: Same as Part 1, except for invalid updates, we need to fix them by re-ordering them
  according to the rules.

  ## Examples

    iex> Day5.fix_incorrectly_ordered_updates("\n47|53\n97|13\n97|61\n97|47\n75|29\n61|13\n75|53\n29|13\n97|29\n53|29\n61|53\n97|53\n61|29\n47|13\n75|47\n97|75\n47|61\n75|61\n47|29\n75|13\n53|13\n\n75,47,61,53,29\n97,61,53,29,13\n75,29,13\n75,97,47,61,53\n61,13,29\n97,13,75,29,47\n")
    123

  """
  def fix_incorrectly_ordered_updates(raw_input) do
    [rule_chunk, update_chunk] = raw_input |> String.trim() |> String.split(~r"\n\n", trim: true)
    rules = parse_rules(rule_chunk)

    split_and_parse(update_chunk, ~r"\,")
    |> Enum.reject(&valid_update(rules, &1))
    |> Enum.map(fn update -> Enum.sort(update, fn a, b -> valid_order(rules, a, b) end) end)
    |> Enum.map(&middle_number/1)
    |> Enum.sum()
  end
end
