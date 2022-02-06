defmodule KB1 do
  use WordmindWeb, :component

  def row(assigns) do
    ~H"""
    <%= for letter <- @letters do %>
      <% class = "letter" %>
      <div class={class}
        phx-click="keypress"
        phx-value-key={letter}
        phx-target={@keyboard_id}
      ><%= letter %></div>
    <% end %>
    """
  end

  def enter(assigns) do
    ~H"""
    <div class="letter wide small">ENTER</div>
    """
  end

  def delete(assigns) do
    ~H"""
    <div class="letter wide large">⌫</div>
    """
  end
end

defmodule WordmindWeb.Live.Game.Keyboard do
  use WordmindWeb, :live_component
  require Logger

  def mount(socket) do
    {:ok, assign(socket, word: []) }
  end

  def handle_event("keypress", info, socket) do
    Logger.info("Keyboard")
    Logger.info(inspect info)
    { :noreply, socket }
  end

  def render(assigns) do

    row1 = "QWERTYUIOP" |> String.codepoints()
    row2 = "ASDFGHJKL" |> String.codepoints()
    row3 = "ZXCVBNM" |> String.codepoints()

    ~H"""
    <div id="keyboard" >

      <div class="kb-row">
        <KB1.row letters={row1} keyboard_id={@id} />
      </div>

      <div class="kb-row">
        <KB1.row letters={row2} keyboard_id={@id} />
      </div>

      <div class="kb-row">
        <KB1.enter/>
        <KB1.row letters={row3} keyboard_id={@id} />
        <KB1.delete/>
      </div>

    </div>
    """
end
end
