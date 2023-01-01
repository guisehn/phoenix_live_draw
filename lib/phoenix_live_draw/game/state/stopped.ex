defmodule PhoenixLiveDraw.Game.State.Stopped do
  alias PhoenixLiveDraw.Game.Room

  defstruct []

  @type t :: %__MODULE__{}

  @behaviour PhoenixLiveDraw.Game.State

  @impl true
  def handle_tick(room), do: {:ok, room}

  @impl true
  def handle_command(room, _player_id, :start) do
    room = if map_size(room.players) > 1, do: Room.build_next_round(room), else: room
    {:ok, nil, room}
  end

  @impl true
  def handle_message(room, player_id, message) do
    Room.broadcast_player_message(room, player_id, message)
    {:ok, nil, room}
  end
end
