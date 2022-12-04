defmodule PhoenixLiveDrawWeb.PlayerSession do
  alias Plug.Conn

  def set_player_id(conn) do
    case get_player_id(conn) do
      nil -> Conn.put_session(conn, "player_id", Ecto.UUID.generate())
      _ -> conn
    end
  end

  def get_player_id(conn), do: Conn.get_session(conn, "player_id")

  @max_length 255
  def set_player_name(conn, name) do
    name = String.trim(name)

    if String.length(name) > 0 do
      Conn.put_session(conn, "player_name", String.slice(name, 0, @max_length))
      true
    else
      false
    end
  end

  def get_player_name(%Conn{} = conn), do: Conn.get_session(conn, "player_name")

  def get_player_name(session) when is_map(session), do: session["player_name"]

  def has_player_name?(session_or_conn), do: !!get_player_name(session_or_conn)
end
