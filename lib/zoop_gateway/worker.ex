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

  def handle_call({:transaction, %{"quantity" => carts} = data} = payload, from, state) do
    carts
    |> Enum.group_by(fn cart -> cart["seller_id"] end)
    |> Enum.map(fn {seller_id, carts} ->
      data =
        data
        |> Map.put("quantity", carts)
        |> Map.put("seller_id", seller_id)
      {seller_id, handle_transaction(split_rules(data), {:transaction, data}, from, state)}
    end)
    |> Enum.map(
      fn
        {seller_id, {:reply, {:ok, order}, _}} -> %{seller_id: seller_id, order: order}
        {seller_id, _} -> %{seller_id: seller_id, order: %{"status" => "ERROR"}}
      end
    )
    |> parse_multi_order(state)
  end

  def handle_call({:boleto, data} = payload, from, state) do
    handle_transaction(split_rules(data), payload, from, state)
  end

  def handle_call({:pix, data} = payload, from, state) do
    handle_transaction(split_rules(data), payload, from, state)
  end

  defp parse_multi_order(resps, state) do
    {:reply, {:ok, resps}, state}
  end

  defp parse_phone(phone) do
     phone =
       phone
       |> String.replace("(", "")
       |> String.replace(")", "")
    "+55 " <> phone
  end

  defp handle_transaction(split, {:boleto, data} = payload, from, state) do
    request(
      :post,
      "/#{state.aldeia_marketplace_id}/buyers",
      Map.new
      |> Map.put("first_name", Enum.at(String.split(data["billing_address"]["name"], " "), 0))
      |> Map.put("last_name", Enum.at(String.split(data["billing_address"]["name"], " "), 1))
      |> Map.put("email", data["billing_address"]["email"])
      |> Map.put("phone_number", parse_phone(data["billing_address"]["phone_no"]))
      |> Map.put("taxpayer_id", data["billing_address"]["cpf"])
      |> Map.put("address", %{
        "line1" => data["billing_address"]["address"],
        "city" => data["billing_address"]["city"],
        "postal_code" =>
          data["billing_address"]["postal_code"]
          |> String.replace(".", "")
          |> String.replace("-", ""),
        "country_code" => "BR",
        "line2" => data["billing_address"]["number"],
        "line3" => data["billing_address"]["complement"],
        "neighborhood" => data["billing_address"]["district"],
        "state" => data["billing_address"]["state"]
      })
    )
    |> IO.inspect
    |> handle_transaction(split, payload, from, state)
  end

  defp handle_transaction({:ok, %{status_code: 201, body: body}} = customer, split, {:boleto, data} = payload, from, state) do
    Map.new
    |> Map.put("on_behalf_of", state.aldeia_seller_id)
    |> Map.put("customer", Map.get(Jason.decode!(body), "id"))
    |> Map.put("amount", calc_amount(split, data))
    |> Map.put("currency", "BRL")
    |> Map.put("description", "VENDA BOLETO")
    |> Map.put("payment_type", "boleto")
    |> Map.put("reference_id", "3")
    |> Map.put("split_rules", split)
    |> handle_transaction(customer, split, payload, from, state)
  end

  defp handle_transaction(req_body, customer, split, {:boleto, data} = payload, from, state) do
    handle_transaction(request(:post, "/#{state.aldeia_marketplace_id}/transactions", req_body), req_body, customer, split, payload, from, state)
  end

  defp handle_transaction(split, {:pix, data} = payload, from, state) do
    Map.new
    |> Map.put("amount", calc_amount(split, data))
    |> Map.put("currency", "BRL")
    |> Map.put("description", "VENDA ALDEIA PET")
    |> Map.put("on_behalf_of", state.aldeia_seller_id)
    |> Map.put("payment_type", "pix")
    |> Map.put("reference_id", "3")
    |> Map.put("split_rules", split)
    |> handle_transaction(split, payload, from, state)
  end

  defp handle_transaction(split, {_, data} = payload, from, state) do
    IO.inspect({"split", split})
    Map.new
    |> Map.put("amount", calc_amount(split, data))
    |> Map.put("currency", "BRL")
    |> Map.put("description", "VENDA ALDEIA PET")
    |> Map.put("capture", true)
    |> Map.put("on_behalf_of", state.aldeia_seller_id)
    |> Map.put("source", generate_source(split, data))
    |> Map.put("payment_type", "credit")
    |> Map.put("split_rules", split)
    |> Map.put("reference_id", "3")
    |> Map.put("installment_plan", %{
        "number_installments" => Map.get(data["installments"], "#{data["seller_id"]}", 1)
    })
    |> handle_transaction(split, payload, from, state)
  end

  defp handle_transaction(req_body, split, payload, from, state) do
    IO.inspect({"payload", req_body})
    handle_transaction(request(:post, "/#{state.aldeia_marketplace_id}/transactions", req_body) |> IO.inspect, req_body, split, payload, from, state)
  end

  defp handle_transaction({:ok, %{status_code: 201, body: body} = request}, _, _, _, _, state) do
    {:reply, {:ok, Jason.decode!(body)}, state}
  end

  defp handle_transaction({:ok, %{status_code: 201, body: body} = request}, _, _, _, {:boleto, _}, _, state) do
    {:reply, {:ok, Jason.decode!(body)}, state}
  end

  defp calc_amount(split, %{"quantity" => carts}) do
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
    products
    |> Enum.group_by(fn cart -> cart["seller_id"] end)
    |> Enum.map(fn {seller_id, prods} ->
       amount = Enum.reduce(prods, 0, fn p, acc ->
         acc + (p["quantity"] * trunc(p["price"] * 100))
       end)

       %{
         "recipient" => Enum.at(prods, 0)["seller"]["zoop"],
         "liable" => 1,
         "is_gross_amount" => true,
         "charge_processing_fee" => 1,
         "amount" => amount + Enum.at(prods, 0)["shipping_cost"]
       }
    end)
  end
end
