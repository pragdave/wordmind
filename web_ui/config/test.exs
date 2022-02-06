import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wordmind, WordmindWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/rSJyAtCnoACFe5csriHInpq5PLlimy6+e0EFbUPGR3WJ7/DiN/93buZevpgm30g",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
