defmodule PhoenixLiveDrawWeb.RoomLive.Stage.DrawingComponent do
  use PhoenixLiveDrawWeb, :live_component

  alias PhoenixLiveDraw.Game.Room

  import PhoenixLiveDrawWeb.CountdownComponent

  def render(assigns) do
    ~H"""
    <main class="w-full h-full">
      <%= if drawing?(@player_id, @room) do %>
        <.word_box room={@room} />
      <% end %>
      <.canvas room={@room} player_id={@player_id} />
      <.bottom_countdown id="drawing_countdown" until={@room.state.expires_at} />
    </main>
    """
  end

  defp word_box(assigns) do
    ~H"""
    <div class="bg-indigo-700 drop-shadow text-white font-bold rounded absolute left-1/2 top-0 -translate-x-1/2 -mt-4 p-2 px-4 z-10 select-none">
      <%= @room.state.word %>
    </div>
    """
  end

  defp canvas(assigns) do
    ~H"""
    <div
      phx-hook="DrawingCanvas"
      phx-update="ignore"
      data-mode={canvas_mode(@player_id, @room)}
      id={"drawing_canvas_#{@player_id}"}
    ></div>
    """
  end

  defp canvas_mode(player_id, room) do
    if drawing?(player_id, room), do: :draw, else: :guess
  end

  defp drawing?(player_id, %Room{round_player: %{id: player_id}}), do: true
  defp drawing?(_, _), do: false
end
