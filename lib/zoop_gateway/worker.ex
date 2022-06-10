defmodule ZoopGateway.Worker do

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, %{
        aldeia_marketplace_id: Application.fetch_env!(:zoop_gateway, :marketplace_id),
        aldeia_seller_id: Application.fetch_env!(:zoop_gateway, :seller_id)
      }
    }
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

  def handle_call({:transaction, data} = payload, _from, state) do
    handle_transaction(split_rules(data), payload, _from, state)
  end

  def handle_call({:pix, data} = payload, _from, state) do
    handle_transaction(split_rules(data), payload, _from, state)
  end

  def handle_transaction(split, {:pix, data} = payload, _from, state) do
    Map.new
    |> Map.put("amount", calc_amount(split, data))
    |> Map.put("currency", "BRL")
    |> Map.put("description", "VENDA ALDEIA PET")
    |> Map.put("on_behalf_of", state.aldeia_seller_id)
    |> Map.put("payment_type", "pix")
    |> Map.put("split_rules", split)
    |> handle_transaction(split, payload, _from, state)
  end

  def handle_transaction(split, {_, data} = payload, _from, state) do
    Map.new
    |> Map.put("amount", calc_amount(split, data))
    |> Map.put("currency", "BRL")
    |> Map.put("description", "VENDA ALDEIA PET")
    |> Map.put("capture", true)
    |> Map.put("on_behalf_of", state.aldeia_seller_id)
    |> Map.put("source", generate_source(split, data))
    |> Map.put("payment_type", "credit")
    |> Map.put("split_rules", split)
    |> handle_transaction(split, payload, _from, state)
  end

  def handle_transaction(req_body, split, payload, _from, state) do
    IO.inspect(req_body)
    handle_transaction(request(:post, "/#{state.aldeia_marketplace_id}/transactions", req_body), req_body, split, payload, _from, state)
  end

  defp handle_transaction({:ok, %{status_code: 201, body: body} = request}, _, _, _, _, state) do
    {:reply, {:ok, Jason.decode!(body)}, state}
  end

  defp calc_amount(split, _data) do
    split
    |> Enum.map(fn s -> s["amount"] end)
    |> Enum.sum()
  end

  defp generate_source(split, data) do
    %{
      "amount" => calc_amount(split, data),
      "usage" => "single_use",
      "currency" => "BRL",
      "type" => "card",
      "card" => data["card"]
    }
  end

  defp split_rules(%{"quantity" => products}) do
    Enum.map(products, fn product ->
      %{
        "recipient" => product["seller_id"],
        "liable" => 1,
        "is_gross_amount" => true,
        "charge_processing_fee" => 1,
        "amount" => product["quantity"] * product["value"]
      }
    end)
  end
end
