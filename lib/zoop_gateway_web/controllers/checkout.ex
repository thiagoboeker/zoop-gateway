defmodule ZoopGatewayWeb.Checkout do
  use ZoopGatewayWeb, :controller

  def checkout(conn, %{"t1" => "pix"} = params) do
    :poolboy.transaction(:transaction_worker, fn pid ->
      GenServer.call(pid, {:pix, params})
    end)
    |> checkout(conn, params)
  end

  def checkout(conn, params) do
    :poolboy.transaction(:transaction_worker, fn pid ->
      GenServer.call(pid, {:transaction, params})
    end)
    |> checkout(conn, params)
  end

  def checkout({:ok, order}, conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{success: true, data: order}))
  end
end
