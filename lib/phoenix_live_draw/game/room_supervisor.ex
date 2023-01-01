defmodule PhoenixLiveDraw.Game.RoomSupervisor do
  use DynamicSupervisor

  alias PhoenixLiveDraw.Game.RoomServer

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: process_ref())
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_room(room_id) do
    opts = [
      id: room_id,
      process_reference: RoomServer.get_process_reference(room_id)
    ]

    DynamicSupervisor.start_child(process_ref(), {RoomServer, opts})
  end

  defp process_ref, do: Process.get(__MODULE__, __MODULE__)

  def setup_local_process_ref,
    do: Process.put(__MODULE__, :"#{__MODULE__}_#{inspect(self())}")
end
