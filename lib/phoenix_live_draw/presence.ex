defmodule PhoenixLiveDraw.Presence do
  use Phoenix.Presence, otp_app: :phoenix_live_draw, pubsub_server: PhoenixLiveDraw.PubSub
end
