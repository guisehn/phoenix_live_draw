defmodule PhoenixLiveDraw.Game.RoomSupervisor do
  use DynamicSupervisor

  alias PhoenixLiveDraw.Game.RoomServer

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_room(room_id) do
    DynamicSupervisor.start_child(__MODULE__, {RoomServer, room_id})
  end
end
