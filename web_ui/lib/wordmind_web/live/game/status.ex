defmodule WordmindWeb.Live.Game.Status do
  use WordmindWeb, :component
  require Logger

  def render(assigns = %{ status: :initializing }) do
    ~H"""
    <div class="status initializing-word" >
    Enjoy your game!
    </div>
    """
  end
  def render(assigns = %{ status: :in_progress }) do
    ~H"""
    """
  end

  def render(assigns = %{ status: :unknown_word, last_word: last_word }) do
    ~H"""
    <div class="status unknown-word" >
    Sorry, I don't know the word "<%= last_word %>"
    </div>
    """
  end

  def render(assigns = %{ status: :already_used, last_word: last_word }) do
    ~H"""
    <div class="status already-used" >
    You already guessed the word "<%= last_word %>"
    </div>
    """
  end

  def render(assigns = %{ status: :won }) do
    ~H"""
    <div class="status won" >
    Congratulations!
    </div>
    """
  end

  def render(assigns = %{ status: :lost, target: target }) do
    ~H"""
    <div class="status lost" >
    Sorry, the word was <span class="target"><%= target %></span>
    </div>
    <a class="button" href="/">Play again</a>
    """
  end


end

