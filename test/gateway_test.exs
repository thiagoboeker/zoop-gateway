defmodule ZoopGateway.GatewayTest do

  use ZoopGatewayWeb.ConnCase, async: false
  @timeout 30_000
  @marketplace_id "cbb404b794094f0081c81bfacc4ceae5"
  @seller_id "cb337326376b485daeed16646953da07"
  @credit_card %{
    card_number: "4539003370725497",
    holder_name: "Julio Alvarenga",
    expiration_month: 3,
    expiration_year: 2027,
    security_code: 123
  }

  test "TRANSACTION" do
    :poolboy.transaction(:transaction_worker, fn pid ->
      GenServer.call(pid, {:transaction, @marketplace_id, %{
        on_behalf_of: @seller_id,
        payment_type: "credit",
        source: %{
          usage: "single_use",
          amount: 700,
          currency: "BRL",
          type: "card",
          card: @credit_card
        }
      }})
    end)
  end

end
