defmodule PhoenixLiveDraw.Game.RoomServer do
  use GenServer

  alias PhoenixLiveDraw.Game.{Player, Room, PubSub}
  alias PhoenixLiveDraw.Presence
  alias Phoenix.Socket.Broadcast

  # Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:id],
      name: opts[:process_reference] || get_process_reference(opts[:id])
    )
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

  def send_command(room_id, player_id, command) do
    room_id |> whereis() |> GenServer.call({:command, player_id, command})
  end

  def send_message(room_id, player_id, message) do
    room_id |> whereis() |> GenServer.call({:message, player_id, message})
  end

  def update(room_id, changes) do
    room_id |> whereis() |> GenServer.cast({:update_room, changes})
  end

  @doc "Returns the PID for the room ID provided, if it exists"
  @spec whereis(term) :: pid() | :undefined
  def whereis(room_id), do: room_id |> get_process_name() |> :global.whereis_name()

  @spec get_process_reference(String.t()) :: {:global, String.t()}
  def get_process_reference(room_id), do: {:global, get_process_name(room_id)}

  @spec get_process_name(String.t()) :: String.t()
  defp get_process_name(room_id), do: "#{process_prefix()}_room_" <> room_id

  defp process_prefix, do: Process.get(:room_process_prefix, "global")

  def setup_local_process_prefix, do: Process.put(:room_process_prefix, inspect(self()))

  # Server
  @impl true
  def init(id) do
    room = Room.new(id)
    :timer.send_interval(:timer.seconds(1), :tick)
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

  def handle_call({:message, player_id, text}, _from, room) do
    {:ok, result, updated_room} = state_module(room).handle_message(room, player_id, text)
    broadcast_changes(room, updated_room)
    {:reply, result, updated_room}
  end

  def handle_call({:command, player_id, command}, _from, room) do
    {:ok, result, updated_room} = state_module(room).handle_command(room, player_id, command)
    broadcast_changes(room, updated_room)
    {:reply, result, updated_room}
  end

  @impl true
  def handle_cast({:update_room, changes}, room) do
    updated_room = Map.merge(room, changes)
    broadcast_changes(room, updated_room)
    {:noreply, updated_room}
  end

  @impl true
  def handle_info(:tick, room) do
    {:ok, updated_room} = state_module(room).handle_tick(room)
    broadcast_changes(room, updated_room)
    {:noreply, updated_room}
  end

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

    if updates != %{} do
      IO.inspect(updates, label: "room changed")
      PubSub.room_broadcast(room.id, {:room_updated, updates})
    end
  end

  defp state_module(room), do: room.state.__struct__
end
