defmodule Helper do
  def list_from_file(file_name) do
    file_name
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split( ~r/\n/, trim: true)
  end
end

defmodule Dictionary.Impl.WordList do

  @type t :: %{
    all_words: MapSet.t(String.t),
    target_words: list(String.t),
  }

  @target_words Helper.list_from_file("../../assets/target_words.txt")
  @other_words  Helper.list_from_file("../../assets/other_words.txt")

  # This is used by the runtime to initialize the agent
  @spec word_list :: t
  def word_list do
    %{
      target_words: @target_words,
      all_words: MapSet.new(@target_words ++ @other_words),
    }
  end

  # and these implement the external API
  @spec pick_target_word(t) :: String.t
  def pick_target_word(word_list) do
    word_list.target_words
    |> Enum.random()
  end

  @spec is_known_word?(t, String.t) :: boolean
  def is_known_word?(word_list, word) do
    word_list.all_words
    |> MapSet.member?(word |> String.upcase(:ascii))
  end



end
