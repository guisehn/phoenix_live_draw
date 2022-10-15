defmodule PhoenixLiveDrawWeb.RoomLive do
  use PhoenixLiveDrawWeb, :live_view

  alias PhoenixLiveDraw.Game.{Player, Room, PubSub}

  alias __MODULE__.{
    MessagesComponent,
    PlayersComponent,
    SimulatorComponent,
    StageComponent
  }

  def mount(%{"id" => room_id}, _session, socket) do
    players = %{
      "1" => Player.new("1", "John"),
      "2" => Player.new("2", "Mari"),
      "3" => Player.new("3", "Richard"),
      "4" => Player.new("4", "Adam")
    }

    room = %{Room.new(room_id) | players: players, round_player: players["1"]}

    socket =
      socket
      |> assign(:room, room)
      |> assign(:player_id, "1")

    PubSub.room_subscribe(room_id)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="w-[900px] h-[572px] m-auto flex flex-row gap-3">
      <div class="w-[660px] flex flex-col gap-3 shrink-0">
        <div class="h-[390px] bg-white rounded rounded-tl-3xl shadow-md shrink-0">
          <StageComponent.render room={@room} player_id={@player_id} />
        </div>

        <div class="h-[170px] bg-white rounded shadow-md shrink-0 rounded-bl-3xl">
          <MessagesComponent.render room={@room} player_id={@player_id} />
        </div>
      </div>

      <div class="grow bg-white rounded rounded-tr-3xl rounded-br-3xl shadow-md overflow-auto break-all">
        <PlayersComponent.list room={@room} />
      </div>
    </div>

    <.live_component id="simulator" module={SimulatorComponent} room={@room} player_id={@player_id} />

    <div class="mt-10 w-1/2 m-auto text-sm">
      <code><pre><%= inspect(@room, pretty: true) %></pre></code>
    </div>
    """
  end

  def handle_info({:update_room, room}, socket) do
    {:noreply, assign(socket, :room, room)}
  end

  def handle_info({:update_player, player_id}, socket) do
    {:noreply, assign(socket, :player_id, player_id)}
  end

  def handle_info({:draw, path}, %{assigns: %{room: room, player_id: player_id}} = socket) do
    guesser? = room.round_player.id != player_id

    if guesser? do
      # Push a "draw" event that will be consumed by the DrawingCanvas hook
      # to replicate the draw object for the guessers
      {:noreply, push_event(socket, :draw, %{path: path})}
    else
      {:noreply, socket}
    end
  end
end
