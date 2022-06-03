defmodule ZoopGateway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ZoopGatewayWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ZoopGateway.PubSub},
      # Start the Endpoint (http/https)
      ZoopGatewayWeb.Endpoint,
      ZoopGateway.poolboy_config(size: 5, overflow: 0)
      # Start a worker by calling: ZoopGateway.Worker.start_link(arg)
      # {ZoopGateway.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ZoopGateway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ZoopGatewayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
