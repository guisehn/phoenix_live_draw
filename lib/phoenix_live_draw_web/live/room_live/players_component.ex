defmodule PhoenixLiveDrawWeb.RoomLive.PlayersComponent do
  use Phoenix.Component

  def list(assigns) do
    ~H"""
    <ul class="divide-y border-b text-xs">
      <%= for {_, player} <- @room.players do %>
        <li class="p-2">
          <div class="text-gray-900 font-medium">
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
end
