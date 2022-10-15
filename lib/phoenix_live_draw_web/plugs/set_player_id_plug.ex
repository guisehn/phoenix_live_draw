defmodule PhoenixLiveDrawWeb.SetPlayerIdPlug do
  @behaviour Plug

  alias PhoenixLiveDrawWeb.PlayerSession

  @impl true
  def init(options), do: options

  @impl true
  def call(conn, _opts), do: PlayerSession.set_player_id(conn)
end
