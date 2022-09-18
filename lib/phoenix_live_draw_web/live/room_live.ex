defmodule PhoenixLiveDrawWeb.RoomLive do
  use PhoenixLiveDrawWeb, :live_view

  alias PhoenixLiveDraw.Game.{Player, Room}
  alias __MODULE__.{MessagesComponent, PlayersComponent}

  def mount(%{"id" => room_id}, _session, socket) do
    players = %{
      "1" => Player.new("1", "John"),
      "2" => Player.new("2", "Mari"),
      "3" => Player.new("3", "Richard"),
      "4" => Player.new("4", "Adam")
    }

    room = %{Room.new(room_id) | players: players}

    socket =
      socket
      |> assign(:room, room)
      |> assign(:player_id, "1")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="w-[900px] h-[572px] m-auto flex flex-row gap-3">
      <div class="w-[660px] flex flex-col gap-3 shrink-0">
        <div class="h-[390px] bg-white rounded rounded-tl-3xl shadow-md shrink-0 flex flex-col items-center justify-center text-center">
          TODO: drawing stage
        </div>

        <div class="h-[170px] bg-white rounded shadow-md shrink-0 rounded-bl-3xl">
          <MessagesComponent.render room={@room} player_id={@player_id} />
        </div>
      </div>

      <div class="grow bg-white rounded rounded-tr-3xl rounded-br-3xl shadow-md overflow-auto break-all">
        <PlayersComponent.list room={@room} />
      </div>
    </div>

    <div class="mt-10 w-1/2 m-auto text-sm">
      <code><pre><%= inspect(@room, pretty: true) %></pre></code>
    </div>
    """
  end
end
