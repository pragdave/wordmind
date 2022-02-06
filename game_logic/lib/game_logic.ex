defmodule GameLogic do

  alias GameLogic.Runtime.Server
  alias GameLogic.Type

  @opaque game :: Server.t

  @spec new_game :: game
  def new_game do
    { :ok, pid } = GameLogic.Runtime.Application.start_game
    pid
  end

  @spec make_move(game, String.t) :: Type.tally
  def make_move(game, guess) do
    GenServer.call(game, { :make_move, guess })
  end
  
  @spec tally(game) :: Type.tally()
  def tally(game) do
    GenServer.call(game, { :tally })
  end

end

