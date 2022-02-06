defmodule Wordmind.Runtime.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WordmindWeb.Telemetry,
      {Phoenix.PubSub, name: Wordmind.PubSub},
      WordmindWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Wordmind.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    WordmindWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
