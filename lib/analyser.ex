defmodule Analyser do
  require IEx

  @speeches_file "speeches.json"

  def analyse_parties(word) do
    load_speeches_file |> word_on_parties(word)
  end

  def analyse_deputies(word) do
    load_speeches_file |> word_on_deputies(word)
  end

  def load_speeches_file do
    { :ok, file } = File.read @speeches_file
    Poison.decode! file
  end

  def word_on_deputies(speeches, word) do
    Enum.reduce(speeches, %{}, fn(speech, map) ->
      party = speech["party"]

      case(speech_contains_word?(speech, word)) do
        true  -> update_parties_count(map, party)
        false -> put_party_in_map(map, party)
      end
    end)
  end

  # Speech has word 
  def update_parties_count(map, party) do
    case(Map.has_key?(map, party)) do
      true -> 
        {a , b} = Map.get(map, party)
        %{ map | party => { a + 1, b + 1 }}
      false -> Map.put(map, party, {1, 1})
    end
  end

  # Speech doesnt have word
  def put_party_in_map(map, party) do
    case(Map.has_key?(map, party)) do
      true -> 
        { a, b } = Map.get(map, party)
        %{ map | party => { a, b + 1 } }
      false -> Map.put(map, party, {0, 1})
    end
  end

  def speech_contains_word?(speech, word) do
    word_count(speech, word) > 0
  end

  def word_on_parties(speeches, word) do
    Enum.reduce(speeches, %{}, fn(speech, map) ->
      count = word_count(speech, word)
      party = speech["party"]

      case(Map.has_key?(map, party))do
        true  -> %{ map | party => Map.get(map, party) + count }
        false -> Map.put(map, party, count)
      end
    end)
  end

  def word_count(speech, word) do
    acc_speech = Enum.join(speech["speeches"]) |> String.split(" ")
    Enum.reduce(acc_speech, 0, fn(s, acc) -> 
      upcased = String.upcase(s)
      case String.contains?(upcased, String.upcase(word)) do
        true  -> acc + 1
        false -> acc
      end
    end)
  end

end
