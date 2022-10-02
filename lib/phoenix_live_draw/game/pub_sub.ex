defmodule PhoenixLiveDraw.Game.PubSub do
  def room_subscribe(room_id) do
    Phoenix.PubSub.subscribe(PhoenixLiveDraw.PubSub, room_topic(room_id))
  end

  def room_broadcast(room_id, data) do
    Phoenix.PubSub.broadcast(PhoenixLiveDraw.PubSub, room_topic(room_id), data)
  end

  defp room_topic(room_id), do: "room:#{room_id}"
end
