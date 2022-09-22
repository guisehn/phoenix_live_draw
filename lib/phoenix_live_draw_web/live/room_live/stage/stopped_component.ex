defmodule PhoenixLiveDrawWeb.RoomLive.Stage.StoppedComponent do
  use PhoenixLiveDrawWeb, :live_component

  def render(assigns) do
    ~H"""
    <main>
      <.title>The game hasn't started yet</.title>

      <%= if map_size(@room.players) < 2 do %>
        <.subtitle>Waiting for players to join</.subtitle>
      <% else %>
        <.button class="mt-3">Start game</.button>
      <% end %>
    </main>
    """
  end
end
