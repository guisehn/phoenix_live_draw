defmodule PhoenixLiveDraw.Game do
  alias __MODULE__.{RoomServer, RoomSupervisor}

  def create_room(id) do
    # id = Ecto.UUID.generate()
    RoomSupervisor.add_room(id)
  end

  def room_exists?(room_id) do
    case RoomServer.whereis(room_id) do
      :undefined -> false
      _pid -> true
    end
  end
end
