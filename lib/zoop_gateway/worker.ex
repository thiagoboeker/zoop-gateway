defmodule ZoopGateway.Worker do

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  defp request(method, url, data) do
    api_key = Application.fetch_env!(:zoop_gateway, :api_key)
    endpoint = Application.fetch_env!(:zoop_gateway, :endpoint)

    HTTPoison.request(
      method,
      endpoint <> url,
      Jason.encode!(data),
      [
        {"Accept", "application/json"},
        {"Authorization", "Basic #{Base.encode64(api_key <> "\:")}"},
        {"Content-Type", "application/json"}
      ]
    )
  end

  def handle_call({:transaction, marketplace_id, data, split}, _from, state) do
    handle_transaction(request(:post, "/#{marketplace_id}/transactions", data), split, state)
  end

  defp handle_transaction({:ok, %{status_code: 201, body: body} = request}, split, state) do
    handle_transaction(Jason.decode!(body), trensaction_request, split, state)
  end

  defp handle_transaction(transaction, request, state) do

  end
end
