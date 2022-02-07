defmodule GameLogic.Impl.Game.ScoreGuess do
  alias GameLogic.Type
  #:nothing | :inexact_match | :exact_match


  @spec guess_with_scores(GameLogic.Impl.Game.t, String.t) :: Type.guess
  def guess_with_scores(game, guess) do
    guess |> String.codepoints |> new_score_guess(game.target)
  end

  def new_score_guess(guess, target) do
    green_results = score_green_letters([], target, guess)
    to_yellow = green_results |> find_yellow_letters(target, guess)
    score_yellows(green_results, guess, to_yellow) #|> match_interface
  end

  # A Quick method to transform the new_score_guess into the version in the tests.
  # TODO, convert tests to use new version.
  @spec score_guess(list(Type.letter), list(Type.letter)) :: list(Type.score)
  def score_guess(guess, target) do
    new_score_guess(guess, target)
    |> Enum.map(fn {_letter, match_type} -> match_type end)
  end

#######################
# Handle Green letters, recurse through the two lists of 5 letters looking for matches
# update the results

  @spec score_green_letters(Type.guess, list(String.t), list(String.t)) :: Type.guess
  def score_green_letters(result, [], []), do: result |> Enum.reverse()
  def score_green_letters(result, [target | target_rest], [guess | guess_rest]) do
    result = [score_green_letter(target, guess) | result]
    score_green_letters(result, target_rest, guess_rest)
  end

  # If letters match, decorate with exact match
  @spec score_green_letter(String.t, String.t) :: Type.letter_with_score
  def score_green_letter(letter, letter) do
    {letter, :exact_match}
  end
  # If letters do not match, decorate with nothing (may be altered when searching for yellows)
  def score_green_letter(_target, guess) do
    {guess, :nothing}
  end

#######################
# we can find the set of yellow letters using the following logic
# collect the correct letters, remove those from both the target and the guess
# remaining letters are the only possible ones to be yellow
# subtract from the set of letters left in the guess, all the letters that
# are not possibly yellowable in the target
# result is a set of letters to "look for" in the guess in order to yellow
# this should account for doubles and so on.

  @spec find_yellow_letters(Type.guess, list(Type.letter), list(Type.letter)) :: list(Type.letter)
  def find_yellow_letters(results, target, guess) do
    #ie target: [k,n,o,t,s], guess: [n,o,r,t,h]
    # [t] is the only correct so far
    correct_so_far = find_exact_match(results)
    #[k,n,o,s] = [k,n,o,t,s] -- [t]
    letters_to_process = target -- correct_so_far
    #[n,o,r,h] = [n,o,r,t,h] -- [t]
    letters_left_in_guess = guess -- correct_so_far
    #[n,o,r,h] -- ([n,o,r,h] -- [k,n,o,s])
    #[n,o,r,h] -- ([r,h])
    #[n,o] is returned
    letters_left_in_guess -- (letters_left_in_guess -- letters_to_process)
  end

  #recurse through the list of letters needing to be yellowed,
  # looking for letters decorated with :nothing and matching
  # the letter to yellow. Once we are out of letters to yellow, return the results
  @spec score_yellows(Type.guess, list(Type.letter), list(Type.letter)) :: Type.guess
  def score_yellows(results, _guess, []), do: results
  def score_yellows(results, guess, [to_yellow | rest]) do
    score_yellows(yellow_one_letter(results, to_yellow), guess, rest)
  end

  @spec yellow_one_letter(Type.guess, Type.letter, Type.guess) :: Type.guess
  defp yellow_one_letter(results, to_yellow, return \\ [])
  # collect the result list until we find a match, then rebuild the
  # result list with the letter set to :inexact_match
  defp yellow_one_letter([{to_yellow, :nothing} | rest], to_yellow, return) do
    Enum.reverse(return) ++ [{to_yellow, :inexact_match}] ++ rest
  end

  #any other decoration that doesn't match the letter or :nothing gets passed through
  defp yellow_one_letter([letter | rest], to_yellow, return) do
    yellow_one_letter(rest, to_yellow, [letter | return])
  end

  #collect all the exact_match letters from our current results
  @spec find_exact_match(Type.guess, list(Type.letter)) :: list(Type.letter)
  def find_exact_match(results, correct_letters \\ [])
  def find_exact_match([], correct_letters), do: correct_letters
  def find_exact_match([{letter, :exact_match} | results], correct_letters) do
    find_exact_match(results, [letter | correct_letters])
  end
  def find_exact_match([_letter | rest], correct_letters) do
    find_exact_match(rest, correct_letters)
  end

   ##################################################
  # score a guess against the target words, where both guess and
  # target are lists of 5 characters.
  #
  # the result is a 5 element array representing the status
  # of the corresponding character in the guess.
  # def score_guess(guess, target) do
  #   old_score_guess(guess, target)
  # end

end
