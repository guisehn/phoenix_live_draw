defmodule PhoenixLiveDraw.Game.RoomServer do
  use GenServer

  alias PhoenixLiveDraw.Game.{Player, Room, PubSub}
  alias PhoenixLiveDraw.Presence
  alias Phoenix.Socket.Broadcast

  # Client
  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: get_process_reference(id))
  end

  @doc """
  Joins a player to a room, subscribes the caller process (the LiveView) to the events
  of the room, and also tracks the caller process, so that the player can be removed
  from the room when the LiveView process dies.
  """
  @spec join(Room.id(), Player.id(), String.t()) :: term
  def join(room_id, player_id, player_name) do
    PubSub.room_subscribe(room_id)
    room_id |> whereis() |> GenServer.call({:join, player_id, player_name, self()})
  end

  @doc "Returns the PID for the room ID provided, if it exists"
  @spec whereis(String.t()) :: pid() | :undefined
  def whereis(room_id), do: room_id |> get_process_name() |> :global.whereis_name()

  @spec get_process_reference(String.t()) :: {:global, String.t()}
  def get_process_reference(room_id), do: {:global, get_process_name(room_id)}

  @spec get_process_name(String.t()) :: String.t()
  defp get_process_name(room_id), do: "room_" <> room_id

  # Server
  @impl true
  def init(id) do
    room = Room.new(id)
    PubSub.room_players_subscribe(id)
    {:ok, room}
  end

  @impl true
  def handle_call({:join, player_id, player_name, pid}, _from, room) do
    # Will trigger `handle_info` with `%Broadcast{event: "presence_diff"}`
    {:ok, _} =
      Presence.track(pid, PubSub.room_players_topic(room.id), player_id, %{name: player_name})

    {:reply, {:ok, room}, room}
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff", payload: diff}, room) do
    updated_room = Room.update_players(room, diff)

    result =
      case map_size(updated_room.players) do
        1 -> {:noreply, Room.stop_game(updated_room)}
        _ -> {:noreply, updated_room}
      end

    broadcast_changes(room, updated_room)

    result
  end

  defp broadcast_changes(room, updated_room) do
    updates = Room.diff(updated_room, room)
    if updates != %{}, do: PubSub.room_broadcast(room.id, {:room_updated, updates})
  end
end
