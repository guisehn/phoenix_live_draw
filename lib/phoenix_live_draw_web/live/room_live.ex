defmodule PhoenixLiveDrawWeb.RoomLive do
  use PhoenixLiveDrawWeb, :live_view

  alias PhoenixLiveDraw.Game
  alias PhoenixLiveDraw.Game.{Room, RoomServer}
  alias PhoenixLiveDrawWeb.PlayerSession

  alias __MODULE__.{
    MessagesComponent,
    PlayersComponent,
    SimulatorComponent,
    StageComponent
  }

  @impl true
  def mount(%{"id" => room_id} = _params, session, socket) do
    if PlayerSession.has_player_name?(session) do
      mount_joining_game(room_id, session, socket)
    else
      mount_dummy_room(room_id, socket)
    end
  end

  defp mount_joining_game(room_id, session, socket) do
    unless Game.room_exists?(room_id), do: Game.create_room(room_id)

    room =
      if connected?(socket) do
        {:ok, room} = RoomServer.join(room_id, session["player_id"], session["player_name"])
        room
      end

    {:ok, assign(socket, room: room, player_id: session["player_id"])}
  end

  defp mount_dummy_room(room_id, socket) do
    room = Room.new(room_id)
    {:ok, assign(socket, room: room, player_id: nil)}
  end

  @impl true
  def render(%{room: nil} = assigns) do
    ~H"""
    <div>Joining...</div>
    """
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

  @impl true
  def handle_info({:room_updated, updates}, socket) do
    updated_room = Map.merge(socket.assigns.room, updates)
    {:noreply, assign(socket, :room, updated_room)}
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
