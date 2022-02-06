defmodule Hangman.Type do 
  @type   state  :: :initializing | :won | :lost | :already_used | :unknown_word
  @type   score  :: :nothing | :inexact_match | :exact_match
  @type   letter :: String.t  # one character
  @type   letter_with_score :: {letter , score }
  @type   guess  :: list(letter_with_score)
  @type   per_letter_score  :: Map.t(String.t, score)

  # this is just the raw word...
  @type   word   :: list(letter)

  @type   tally  :: %{
    game_state:  state,
    guesses:     list(guess),
    raw_guesses: list(String.t),
    target:      String.t,
    alphabet:    per_letter_score,
  }

end
