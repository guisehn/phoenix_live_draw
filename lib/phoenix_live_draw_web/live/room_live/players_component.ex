defmodule PhoenixLiveDrawWeb.RoomLive.PlayersComponent do
  use PhoenixLiveDrawWeb, :component

  alias PhoenixLiveDraw.Game.{Room, State}

  def list(assigns) do
    ~H"""
    <ul class="divide-y border-b text-xs">
      <%= for {_, player} <- @room.players do %>
        <li class="p-2">
          <div class="text-gray-900 font-medium">
            <%= if drawing?(player, @room) do %>
              <.pencil_icon class="inline-block w-4" />
            <% end %>
            <%= player.name %>
          </div>
          <div class="text-gray-500">
            <%= player.points %> points
          </div>
        </li>
      <% end %>
    </ul>
    """
  end

  defp drawing?(
         _player = %{id: player_id},
         _room = %Room{state: %State.Drawing{}, round_player: %{id: player_id}}
       ),
       do: true

  defp drawing?(_, _), do: false
end
