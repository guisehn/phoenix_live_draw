defmodule PhoenixLiveDrawWeb.RoomLive.Stage.DrawingComponent do
  use PhoenixLiveDrawWeb, :live_component

  alias PhoenixLiveDraw.Game.Room

  import PhoenixLiveDrawWeb.CountdownComponent

  def render(assigns) do
    ~H"""
    <main>
      <%= if drawing?(assigns) do %>
        <div class="bg-indigo-700 drop-shadow text-white font-bold rounded absolute left-1/2 top-0 -translate-x-1/2 -mt-4 p-2 px-4">
          <%= @room.state.word %>
        </div>
      <% end %>
      <.bottom_countdown id="drawing_countdown" until={@room.state.expires_at} />
    </main>
    """
  end

  defp drawing?(%{player_id: player_id, room: %Room{round_player: %{id: player_id}}}), do: true
  defp drawing?(_), do: false
end
