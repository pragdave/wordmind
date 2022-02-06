defmodule KB2 do
  use WordmindWeb, :component
  require Logger
  def row(assigns) do
    ~H"""
    <%= for letter <- @letters do %>
      <% class = "letter #{assigns.classes[letter]}" %>
      <div class={class}
        phx-click="keypress"
        phx-value-key={letter}
      ><%= letter %></div>
    <% end %>
    """
  end

  def enter(assigns) do
    attrs = if assigns.enabled do
      %{
        class: "letter wide small",
        "phx-click": "keypress",
        "phx-value-key": "Enter",
      }
      else
      %{
        class: "letter wide small disabled",
      }
    end
    ~H"""
    <div {attrs}>ENTER</div>
    """
  end

  def delete(assigns) do
    big_button(assigns, "large", "⌫")
  end

  defp big_button(assigns, font_size, label) do
    attrs = if assigns.enabled do
      %{
        class: "letter wide #{font_size}",
        "phx-click": "keypress",
        "phx-value-key": "Enter",
      }
      else
      %{
        class: "letter wide #{font_size} disabled",
      }
    end
    ~H"""
    <div {attrs}><%= label %></div>
    """
  end
end

defmodule WordmindWeb.Live.Game.KB do
  use WordmindWeb, :component
  require Logger


  def draw(assigns) do
    row1 = "QWERTYUIOP" |> String.codepoints()
    row2 = "ASDFGHJKL" |> String.codepoints()
    row3 = "ZXCVBNM" |> String.codepoints()

    ~H"""
    <div id="keyboard" >

      <div class="kb-row">
        <KB2.row letters={row1} classes={@alphabet} />
      </div>

      <div class="kb-row">
        <KB2.row letters={row2} classes={@alphabet} />
      </div>

      <div class="kb-row">
        <KB2.enter enabled={@input_length == 5}/>
        <KB2.row letters={row3} classes={@alphabet} />
        <KB2.delete enabled={@input_length > 0}/>
      </div>

    </div>
    """
end
end

