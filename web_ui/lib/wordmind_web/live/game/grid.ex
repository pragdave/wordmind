defmodule Row do
  use WordmindWeb, :component

  def render(assigns) do
    ~H"""
    <div class="grid-row">
    <%= for ({ letter, class }) <- @row do %>
      <% class = "cell #{class}" %>
      <div class={class}><span><%= letter %></span></div>
    <% end %>
    </div>
    """
  end


  def input(assigns) do
    chars = assigns.characters
    ~H"""
    <div class="grid-row input">
    <%= for letter <- chars do %>
      <div class="cell input"><span><%= letter %></span></div>
      <% end %>
    <%= if length(chars) < 5 do %>
      <%= for _i <- length(chars)..4 do %>
        <div class="cell input"></div>
      <% end %>
    <% end %>
    </div>
    """
  end
end

defmodule Spacer do
  use WordmindWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <Row.render row={empty_row(:nothing)} />
    </div>
    """
  end

  defp empty_row(class) do
    List.duplicate({ " ", class }, 5)
  end
end

defmodule WordmindWeb.Live.Game.Grid do
  use WordmindWeb, :live_component

  def render(assigns) do
    guesses = assigns.tally.guesses
    guess_count = length(guesses)
    spacers = 6 - guess_count - 1
    over = assigns.tally.game_state in [ :won, :lost ]

    ~H"""
    <div class="guess-grid">
      <%= if guess_count < 6 && !over do %>
        <Row.input characters={@input_buffer} />
      <% end %>

      <%= for row <- guesses do %>
        <Row.render row={row}/>
        <% end %>

      <%= if spacers > 0 && !over do  %>
        <%= for i <- length(guesses)..4 do %>
          <.live_component module={Spacer} id={i} />
        <% end %>
      <% end %>
    </div>
    """
  end
end
