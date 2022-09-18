defmodule PhoenixLiveDrawWeb.RoomLive.MessagesComponent do
  alias PhoenixLiveDraw.Game.{PlayerMessage, SystemMessage}

  use Phoenix.Component

  def render(assigns) do
    messages = [
      %PlayerMessage{name: "Mari", body: "hi"},
      %SystemMessage{body: "John is drawing now"},
      %PlayerMessage{name: "Adam", body: "cat"},
      %PlayerMessage{name: "Richard", body: "dog"},
      %PlayerMessage{name: "Mari", body: "pet"},
      %PlayerMessage{name: "Richard", body: "bark"},
      %PlayerMessage{name: "Adam", body: "animal"}
    ]

    ~H"""
    <div class="h-full flex-col gap-y-0.5 p-2 pb-4">
      <ul class="overflow-auto h-4/5 text-sm p-4">
        <%= for message <- messages do %>
          <li><.message message={message} /></li>
        <% end %>
      </ul>

      <%= unless my_round?(assigns) do %>
        <.message_form />
      <% end %>
    </div>
    """
  end

  defp message_form(assigns) do
    ~H"""
    <form
      id="message_form"
      class="h-1/5"
    >
      <input
        type="text"
        name="msg"
        class="rounded border border-gray-200 w-full rounded-3xl bg-gray-100 border-0 text-sm"
        placeholder="Guess and chat here..."
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

  defp my_round?(%{room: room, user_id: user_id}) do
    room.round_player && room.round_player.id == user_id
  end
end
