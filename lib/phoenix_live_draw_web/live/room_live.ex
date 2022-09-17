defmodule PhoenixLiveDrawWeb.RoomLive do
  use PhoenixLiveDrawWeb, :live_view

  alias PhoenixLiveDraw.Game.Room

  def mount(%{"id" => room_id}, _session, socket) do
    {:ok, assign(socket, :room, Room.new(room_id))}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="w-[900px] h-[572px] m-auto flex flex-row gap-3">
      <div class="w-[660px] flex flex-col gap-3 shrink-0">
        <div class="h-[390px] bg-white rounded rounded-tl-3xl shadow-md shrink-0">
          stage
        </div>

        <div class="h-[170px] bg-white rounded shadow-md shrink-0 rounded-bl-3xl">
          messages
        </div>
      </div>

      <div class="grow bg-white rounded rounded-tr-3xl rounded-br-3xl shadow-md overflow-auto break-all">
        players
      </div>
    </div>

    <div class="mt-10 w-1/2 m-auto text-sm">
      <code><pre><%= inspect(@room, pretty: true) %></pre></code>
    </div>
    """
  end
end
