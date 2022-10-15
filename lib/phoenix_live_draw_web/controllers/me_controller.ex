defmodule PhoenixLiveDrawWeb.MeController do
  use PhoenixLiveDrawWeb, :controller

  def update(conn, %{"player" => player}) do
    conn
    |> put_session("player_name", player["name"])
    |> redirect(to: player["redirect_to"] || "/")
  end
end
