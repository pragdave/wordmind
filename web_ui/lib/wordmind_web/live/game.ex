defmodule WordmindWeb.Live.Game do
  use WordmindWeb, :live_view
  require Logger

  alias __MODULE__.KB
  alias __MODULE__.Status

  def mount(_params, _session, socket) do
    game = GameLogic.new_game()
    tally = GameLogic.tally(game)
    { :ok,
      assign(socket, %{
        last_word: "",
        game: game, 
        tally: tally, 
        input_buffer: [],
      })
    }
  end

  def handle_event("keypress", %{ "key" => key }, socket) when key in [ "Backspace", "Delete" ] do
    buffer = socket.assigns.input_buffer
    buffer = if length(buffer) > 0 do 
      buffer |> List.delete_at(length(buffer)-1)
    else
      buffer
    end

    socket = socket |> assign(%{ input_buffer: buffer })
    { :noreply, socket }
  end

  def handle_event("keypress", %{ "key" => "Enter" }, socket) do
    buffer = socket.assigns.input_buffer
    if length(buffer) == 5 do 
      guess = buffer |> Enum.join("")
      tally = GameLogic.make_move(socket.assigns.game, guess)
      {
        :noreply,
        socket |> assign(%{
          input_buffer: [],
          tally:  tally,
          last_word: guess,
        })
      }
    else
      { :noreply, socket }
    end
  end

  def handle_event("keypress", info, socket) do
    key = info["key"]
    buffer = socket.assigns.input_buffer

    if is_letter?(key) && length(buffer) < 5 do 
      {
        :noreply,
        socket |> assign(:input_buffer, buffer ++ [ String.upcase(key) ])
      }
    else 
      { :noreply, socket }
    end
  end

  def is_letter?(key) do
    (String.length(key) == 1) &&
      (
        (key >= "a" && key <= "z") ||
        (key >= "A" && key <= "Z")
      )
  end

  def render(assigns) do
    alphabet = %{ alphabet: assigns.tally.alphabet, input_length: length(assigns.input_buffer) }
    ~H"""
    <div class="game-holder" phx-window-keyup="keypress">
    <%= live_component(__MODULE__.Grid,  input_buffer: @input_buffer, tally: assigns.tally, id: 1) %>
    <KB.draw {alphabet} />
    <Status.render 
       status={@tally.game_state} 
       last_word={@last_word} 
       target={@tally.target}/>
    </div>
    """
  end
end
