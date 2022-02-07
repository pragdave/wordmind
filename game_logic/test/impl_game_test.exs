defmodule Helper do
end

defmodule GameLogicImplGameTest do
  use ExUnit.Case
  alias GameLogic.Impl.Game

  defp s(str), do: str |> String.codepoints()

  test "new game returns structure" do
    game = Game.new_game()
    assert game.game_state == :initializing
    assert length(game.target) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("koala")
    assert game.game_state == :initializing
    assert game.target == ["K", "O", "A", "L", "A"]
  end


  def run_game(script, target) do
    game = Game.new_game(target)
    script |> Enum.reduce(game, fn ([ guess, score, state ], game) -> 
      { game, tally } = Game.make_move(game, guess)
      assert tally.game_state == state
      guess_with_scores = hd(tally.guesses)
      actual_letters = guess_with_scores |> Enum.map(&elem(&1, 0)) |> Enum.join
      actual_score   = guess_with_scores |> Enum.map(&elem(&1, 1))
      assert actual_letters == guess
      assert actual_score == score
      game
    end
    )
  end

  def score(abbrev) do
    abbrev
    |> String.codepoints()
    |> Enum.map(fn letter -> 
      case letter do
        "n" -> :nothing
        "i" -> :inexact_match
        "e" -> :exact_match
      end
    end)
  end

  test "game correctly scores no matches" do
    [
      [ "BEGEM", score("nnnnn"), :in_progress]
    ]
    |> run_game("KOALA") 
  end

  test "game correctly scores inexact matches" do
    [
      [ "BEGAD", score("nnnin"), :in_progress]
    ]
    |> run_game("KOALA") 
  end

  test "game correctly scores exact matches" do
    [
      [ "BEAMY", score("nnenn"), :in_progress]
    ]
    |> run_game("KOALA") 
  end

  test "game correctly scores win" do
    [
      [ "KOALA", score("eeeee"), :won]
    ]
    |> run_game("KOALA") 
  end



  test "scoring with no matches" do 
    result = Game.score_guess(s("ABCDE"), s("VWXYZ"))
    assert result == [ :nothing, :nothing, :nothing, :nothing, :nothing ]
  end

  test "scoring with one inexact match" do 
    result = Game.score_guess(s("ABCDE"), s("VWXAZ"))
    assert result == [ :inexact_match, :nothing, :nothing, :nothing, :nothing ]
  end

  test "scoring with one inexact match but two matches in target" do 
    result = Game.score_guess(s("ABCDE"), s("VWAAZ"))
    assert result == [ :inexact_match, :nothing, :nothing, :nothing, :nothing ]
  end

  test "scoring with two inexact matches of duplicate in target" do 
    result = Game.score_guess(s("ABCDA"), s("VWAAZ"))
    assert result == [ :inexact_match, :nothing, :nothing, :nothing, :inexact_match ]
  end

  test "scoring with two inexact matches of different letters" do 
    result = Game.score_guess(s("ABCDA"), s("VWACZ"))
    assert result == [ :inexact_match, :nothing, :inexact_match, :nothing, :nothing ]
  end

  test "scoring with one exact match" do 
    result = Game.score_guess(s("ABCDE"), s("VBXYZ"))
    assert result == [ :nothing, :exact_match, :nothing, :nothing, :nothing ]
  end

  test "scoring with two exact match" do 
    result = Game.score_guess(s("ABCDB"), s("VBXYB"))
    assert result == [ :nothing, :exact_match, :nothing, :nothing, :exact_match ]
  end

  test "scoring with two exact matches different letters" do 
    result = Game.score_guess(s("ABCDE"), s("VBXYE"))
    assert result == [ :nothing, :exact_match, :nothing, :nothing, :exact_match ]
  end

  test "scoring with all exact matches different letters" do 
    result = Game.score_guess(s("ABCDE"), s("ABCDE"))
    assert result == [ :exact_match, :exact_match, :exact_match, :exact_match, :exact_match ]
  end

  test "scoring with all inexact matches different letters" do 
    result = Game.score_guess(s("BCDEA"), s("ABCDE"))
    assert result == [ :inexact_match, :inexact_match, :inexact_match, :inexact_match, :inexact_match ]
  end

  test "scoring where exact match should trump inexact match" do
    result = Game.score_guess(s("ABBDE"), s("XXBXX"))
    assert result == [ :nothing, :nothing, :exact_match, :nothing, :nothing ]
  end

  test "scoring where exact match should trump inexact match (2)" do
    result = Game.score_guess(s("AABBE"), s("XXBXX"))
    assert result == [ :nothing, :nothing, :exact_match, :nothing, :nothing ]
  end

  test "scoring with exact and inexact matches of same letter" do
    result = Game.score_guess(s("AABBE"), s("BXBXX"))
    assert result == [ :nothing, :nothing, :exact_match, :inexact_match, :nothing ]
  end

  @alphabet "ABCDEFGHIJLKMNOPQRSTUVWXYZ" |> String.codepoints()

  test "initial alphabet has no matches" do
    game = Game.new_game("KOALA")
    @alphabet |> Enum.each(fn letter -> assert game.alphabet[letter] == :unused end) 
  end
  
  test "alphabet reflects matches" do
    game = Game.new_game("KOALA")
    { _game, tally } = Game.make_move(game, "CHALK")
    a = tally.alphabet
    assert a["A"] == :exact_match
    assert a["L"] == :exact_match
    assert a["K"] == :inexact_match
  end
end
