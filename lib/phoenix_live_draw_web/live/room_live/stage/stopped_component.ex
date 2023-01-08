defmodule PhoenixLiveDrawWeb.RoomLive.Stage.StoppedComponent do
  use PhoenixLiveDrawWeb, :live_component

  alias PhoenixLiveDraw.Game.RoomServer

  @impl true
  def render(assigns) do
    ~H"""
    <main>
      <.title>The game hasn't started yet</.title>

      <%= if map_size(@room.players) < 2 do %>
        <.subtitle>Waiting for players to join</.subtitle>
      <% else %>
        <.button
          class="mt-3"
          phx-click="start_game"
          phx-target={@myself}
        >
          Start game
        </.button>
      <% end %>
    </main>
    """
  end

  @impl true
  def handle_event("start_game", _, socket) do
    RoomServer.send_command(socket.assigns.room.id, socket.assigns.player_id, :start)
    {:noreply, socket}
  end
end
