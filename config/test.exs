import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ascee, AsceeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "RemDXnXxv/8Q7Nyw29TXIpTr7S5ipWk+OVz+GkkFgmaE7A5ga91CckBiyy8gg8zg",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
