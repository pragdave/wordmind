defmodule GameLogic.Impl.Game do

  alias GameLogic.Type
  alias GameLogic.Impl.Game.ScoreGuess

  # This is the state of the alphabet before the first guess
  @initial_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                      |> String.codepoints()
                      |> Enum.map(&{&1, :unused})
                      |> Map.new


  @type t :: %__MODULE__{
    game_state: GameLogic.state,
    target:     list(String.t),
    guesses:    list(Type.guess),
    raw_guesses: list(String.t),
    alphabet:   Type.per_letter_score,
  }

  defstruct(
    game_state: :initializing,
    target:    [],
    guesses:   [],
    raw_guesses: [],
    alphabet:  @initial_alphabet
  )

  #defdelegate guess_with_scores(game, guess), to: GameLogic.Impl.Game.ScoreGuess


  ##################################################

  @spec new_game(String.t) :: t
  def new_game(word \\ Dictionary.pick_target_word) do
    %__MODULE__{
      target: word |> String.upcase |> String.codepoints
    }
  end

  ##################################################

  @spec make_move(t, String.t) :: { t, Type.tally }
  def make_move(game, guess) do
    guess
    |> String.upcase
    |> update_state_from_guess(game)
    |> return_with_tally()
  end

  ##################################################

  @spec update_state_from_guess(String.t, t) :: t
  def update_state_from_guess(guess, game) do

    cond do
      game.game_state in [ :won, :lost ] ->
        game

      Enum.member?(game.raw_guesses, guess) ->
        %{ game | game_state: :already_used }

      Dictionary.is_known_word?(guess) ->
        accept_guess(game, guess)

      true ->
        %{ game | game_state: :unknown_word }
    end
  end

  ##################################################

  @spec accept_guess(t, String.t) :: t
  defp accept_guess(game, guess) do
    %{
      game | raw_guesses: [ guess | game.raw_guesses ],
      guesses: [ ScoreGuess.guess_with_scores(game, guess) | game.guesses ]
    }
    |> update_game_state()
  end

  ##################################################

  # @spec guess_with_scores(t, String.t) :: Type.guess
  # defp guess_with_scores(game, guess) do
  #   guess = guess |> String.codepoints
  #   Enum.zip(guess, score_guess(guess, game.target))
  # end


  @spec update_game_state(t) :: t
  defp update_game_state(game = %{ guesses: guesses }) do
    cond do
      length(guesses) == 0 ->   # shouldn't happen, but makes dialzer happy
        game
      all_correct(hd(guesses)) ->
        %{ game | game_state: :won }
      length(guesses) == 6 ->
        %{ game | game_state: :lost }
      true ->
        %{ game | game_state: :in_progress }
    end
  end

  defp all_correct(guess) do
    Enum.all?(guess, fn ({_letter, score}) ->
      score == :exact_match
    end)
  end

  # ##################################################
  # # score a guess against the target words, where both guess and
  # # target are lists of 5 characters.
  # #
  # # the result is a 5 element array representing the status
  # # of the corresponding character in the guess.


  # def score_guess(guess, target) do
  #   #          guess  target  result
  #   Enum.zip([ guess, target, List.duplicate(:nothing, 5)])
  #   |> score_and_remove_green_matches()
  #   |> score_yellow_matches()
  # end

  # # this is the easy one: entries where the guess letter equals the
  # # target letter have an `:exact_match` in the result.
  # defp score_and_remove_green_matches(gtrs) do
  #   Enum.map(gtrs, fn gtr ->
  #     case gtr do
  #       { same_letter, same_letter, _result } ->
  #         { :used_guess, :used_target, :exact_match }
  #       _ ->
  #         gtr
  #     end
  #   end)
  # end

  # # For the inexact matches, we first construct a list of target
  # # letters with any exact matches removed. For each letter in the
  # # guess, we see if the same letter is in the target list.
  # # If so, we record an `:inexact_guess`, and then remove that
  # # occurence of the letter from the target list.

  # defp score_yellow_matches(gtr) do
  #   gtr
  #   |> Enum.map(fn ({_g, t, _r}) -> t end)
  #   |> Enum.reject(&(&1 == :used_target))
  #   |> score_guess_letter_in_remaining(gtr, [])
  #   |> Enum.reverse
  # end

  # defp score_guess_letter_in_remaining(_, [], result) do
  #   result
  # end

  # defp score_guess_letter_in_remaining(remaining, [ {g, _t, r} | rest], result) do
  #   case Enum.find_index(remaining, &(&1 == g)) do
  #     nil ->
  #       score_guess_letter_in_remaining(remaining, rest, [ r | result ])
  #     match_index ->
  #       score_guess_letter_in_remaining(
  #         remaining |> List.delete_at(match_index),
  #         rest,
  #         [ :inexact_match | result ]
  #       )
  #   end
  # end

  @spec tally(t) :: Type.tally
  def tally(game) do
    %{
      game_state:  game.game_state,
      guesses:     game.guesses,
      raw_guesses: game.raw_guesses,
      alphabet:    game.alphabet,
      target:     (
        if game.game_state in [:won, :lost],
          do:   game.target |> Enum.join(""),
          else: "?????"
      )
    }
  end

  @spec return_with_tally(t) :: { t, Type.tally }
  defp return_with_tally(game) do
    game = %{ game | alphabet: letter_state_for(game) }
    { game, tally(game) }
  end

  # As an optimization we only update the alphabet with
  # letters from the current guess. This means we have to
  # handle the case where there's no guesses yet (for
  # example if there's an invalid word on the first attempt).

  defp letter_state_for(game = %{ guesses: [ current_guess | _others ]}) do
    current_guess
    |> Enum.reduce(game.alphabet, fn ({letter, score}, alphabet)->
      old_score = alphabet[letter]
      case { old_score,score } do
        { same, same }               -> alphabet
        { _, :exact_match }          -> alphabet |> Map.put(letter, score)
        { :nothing, :inexact_match } -> alphabet |> Map.put(letter, score)
        { :unused,  :inexact_match } -> alphabet |> Map.put(letter, score)
        { :unused,  :nothing }       -> alphabet |> Map.put(letter, score)
        _                            -> alphabet
      end
    end)
  end

  defp letter_state_for(%{ alphabet: alphabet }) do
    alphabet
  end
end
