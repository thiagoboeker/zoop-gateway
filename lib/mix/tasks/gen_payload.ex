defmodule Mix.Tasks.GenPayload do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task

  @alt_seller_id "c29cbb91a5fb49c192dddf34fe38e1f3"

  @payload %{
      "payment_type" => 0,
      "sub_total" => 160.11,
      "discount_offer" => 0,
      "shipping_tax" => 0,
      "tax" => 0,
      "coupon_discount" => 0,
      "total" => 160.11,
      "quantity" => [
          %{
              "id" => 9,
              "url" => "https =>//m.media-amazon.com/images/I/517DTupFR3L._AC_SX466_.jpg",
              "quantity" => 1,
              "value" => 120,
              "name" => "Racao Pedigree Adulto",
              "seller" => "Aldeia PET",
              "seller_id" => @alt_seller_id,
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
          "created_at" => "2022-04-22T00:58:47.000000Z",
          "updated_at" => "2022-04-22T00:58:47.000000Z"
      }
    }

  @shortdoc "Simply calls the Hello.say/0 function."
  def run(_) do
    # calling our Hello.say() function from earlier
    IO.inspect(Base.encode64(Jason.encode!(@payload)))
  end
end
