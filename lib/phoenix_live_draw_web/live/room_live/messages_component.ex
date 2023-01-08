defmodule PhoenixLiveDrawWeb.RoomLive.MessagesComponent do
  alias PhoenixLiveDraw.Game.{PlayerMessage, RoomServer, SystemMessage}

  use PhoenixLiveDrawWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex-col gap-y-0.5 p-2 pb-4">
      <ul
        id="messages-list"
        phx-update="append"
        class="overflow-auto h-4/5 text-sm p-4"
        phx-hook="MessageList"
      >
        <%= for message <- @messages do %>
          <li id={"message-#{message.id}"}><.message message={message} /></li>
        <% end %>
      </ul>

      <%= unless my_round?(assigns) do %>
        <.message_form {assigns} />
      <% end %>
    </div>
    """
  end

  defp message_form(assigns) do
    ~H"""
    <form
      id="message_form"
      class="h-1/5"
      phx-submit="send"
      phx-target={@myself}
      phx-hook="MessageForm"
    >
      <input
        type="text"
        name="msg"
        class="rounded border border-gray-200 w-full rounded-3xl bg-gray-100 border-0 text-sm"
        placeholder="Guess and chat here..."
        autocomplete="off"
      />
    </form>
    """
  end

  defp message(%{message: %PlayerMessage{}} = assigns) do
    ~H"""
    <b><%= @message.name %>:</b> <%= @message.body %>
    """
  end

  defp message(%{message: %SystemMessage{}} = assigns) do
    ~H"""
    <div class="font-semibold text-indigo-500"><%= @message.body %></div>
    """
  end

  defp my_round?(%{room: room, player_id: player_id}) do
    room.round_player && room.round_player.id == player_id
  end

  @impl true
  def handle_event("send", %{"msg" => msg}, socket) do
    msg = String.trim(msg)

    if msg != "" do
      RoomServer.send_message(socket.assigns.room.id, socket.assigns.player_id, msg)
    end

    {:noreply, socket}
  end
end
