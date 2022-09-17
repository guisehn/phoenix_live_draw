import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_live_draw, PhoenixLiveDrawWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Zu/2YU4xdu02lmjfO9NLxgHvDPCVl2G//5E06MQwgH4ZLPC9nktuY+pVsYwR7rTR",
  server: false

# In test we don't send emails.
config :phoenix_live_draw, PhoenixLiveDraw.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
