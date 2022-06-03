use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :zoop_gateway, ZoopGatewayWeb.Endpoint,
  http: [port: 4002],
  server: false


config :zoop_gateway, :api_key, "zpk_test_bwlMYmQdPu0X2CtLWku4XiRf"
config :zoop_gateway, :endpoint, "https://api.zoop.ws/v1/marketplaces"

# Print only warnings and errors during test
config :logger, level: :warn
