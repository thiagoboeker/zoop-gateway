defmodule ZoopGateway do
  @moduledoc """
  ZoopGateway keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def poolboy_config(size: size, overflow: overflow) do
    :poolboy.child_spec(:transaction_worker, [
      name: {:local, :transaction_worker},
      worker_module: ZoopGateway.Worker,
      size: size,
      max_overflow: overflow
    ])
  end
end
