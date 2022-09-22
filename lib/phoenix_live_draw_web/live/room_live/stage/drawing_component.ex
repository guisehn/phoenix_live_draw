defmodule PhoenixLiveDrawWeb.RoomLive.Stage.DrawingComponent do
  use PhoenixLiveDrawWeb, :live_component

  alias PhoenixLiveDraw.Game.Room

  def render(assigns) do
    ~H"""
    <main>
      <%= if drawing?(assigns) do %>
        the word is: <%= @room.state.word %>
      <% end %>
    </main>
    """
  end

  defp drawing?(%{player_id: player_id, room: %Room{round_player: %{id: player_id}}}), do: true
  defp drawing?(_), do: false
end
