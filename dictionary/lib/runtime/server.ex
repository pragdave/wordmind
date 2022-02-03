defmodule Dictionary.Runtime.Server do

  @type t :: pid()

  @me __MODULE__

  use Agent

  alias Dictionary.Impl.WordList

  def start_link(_) do
    Agent.start_link(&WordList.word_list/0, name: @me)
  end

  def pick_target_word() do
    Agent.get(@me, &WordList.pick_target_word/1)
  end

  def is_known_word?(word) do
    Agent.get(@me, fn word_list -> WordList.is_known_word?(word_list, word) end)
  end
end
