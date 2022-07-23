defmodule ZoopGateway.GatewayTest do

  use ZoopGatewayWeb.ConnCase, async: false
  @timeout 30_000
  @marketplace_id "cbb404b794094f0081c81bfacc4ceae5"
  @alt_seller_id "c29cbb91a5fb49c192dddf34fe38e1f3"
  @seller_id "cb337326376b485daeed16646953da07"
  @credit_card %{
    card_number: "4539003370725497",
    holder_name: "Julio Alvarenga",
    expiration_month: 3,
    expiration_year: 2027,
    security_code: 123
  }

  @payload %{
    "payment_type" => 0,
    "sub_total" => 160.11,
    "discount_offer" => 0,
    "shipping_tax" => 0,
    "tax" => 0,
    "coupon_discount" => 0,
    "total" => 160.11,
    "installments" => %{
      "1" => 1
    },
    "card" => %{
      "card_number" => "4539003370725497",
      "holder_name" => "Julio Alvarenga",
      "expiration_month" => 3,
      "expiration_year" => 2027,
      "security_code" => 123
    },
    "quantity" => [
        %{
            "id" => 9,
            "shipping_cost" => 500,
            "url" => "https =>//m.media-amazon.com/images/I/517DTupFR3L._AC_SX466_.jpg",
            "quantity" => 1,
            "price" => 6560,
            "name" => "Racao Pedigree Adulto",
            "seller" => %{
                "zoop" => "c29cbb91a5fb49c192dddf34fe38e1f3"
            },
            "seller_id" => 1,
            "description" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur"
        }
    ],
    "coupon" => [],
    "checkout_method" => 2,
    "shipping_address" => %{
        "id" => 1,
        "user_id" => 2,
        "name" => "DAVI DIAS DE SOUSA",
        "email" => "davidiasdesousa@gmail.com",
        "phone_no" => "+55 27 88889 9999",
        "address" => "Rua Rio Grande do Norte",
        "address_ids" => %{
            "country_id" => "31",
            "state_id" => "7",
            "city_id" => "4"
        },
        "country" => "Brazil",
        "state" => "Espírito Santo",
        "city" => "Alegre",
        "latitude" => nil,
        "longitude" => nil,
        "postal_code" => "29141460",
        "default_shipping" => 1,
        "default_billing" => 1,
        "created_at" => "2022-04-22T00 =>58 =>47.000000Z",
        "updated_at" => "2022-04-22T00 =>58 =>47.000000Z"
    },
    "billing_address" => %{
        "id" => 1,
        "user_id" => 2,
        "name" => "DAVI DIAS DE SOUSA",
        "email" => "davidiasdesousa@gmail.com",
        "phone_no" => "+55 27 88889 9999",
        "address" => "Rua Rio Grande do Norte",
        "number" => "105",
        "complement" => "Casa",
        "cpf" => "13206867703",
        "district" => "Conquista",
        "address_ids" => %{
            "country_id" => "31",
            "state_id" => "7",
            "city_id" => "4"
        },
        "country" => "Brazil",
        "state" => "ES",
        "city" => "Alegre",
        "latitude" => nil,
        "longitude" => nil,
        "postal_code" => "29141460",
        "default_shipping" => 1,
        "default_billing" => 1,
        "created_at" => "2022-04-22T00:58:47.000000Z",
        "updated_at" => "2022-04-22T00:58:47.000000Z"
    }
  }

  test "TRANSACTION" do
    build_conn()
    |> post("/api/checkout", @payload)
    |> json_response(200)
    |> IO.inspect
  end

  test "PIX" do
    build_conn()
    |> post("/api/checkout?t1=pix", @payload)
    |> json_response(200)
    |> IO.inspect
  end

  test "BOLETO" do
    build_conn()
    |> post("/api/checkout?t1=boleto", @payload)
    |> json_response(200)
    |> IO.inspect
  end

end
