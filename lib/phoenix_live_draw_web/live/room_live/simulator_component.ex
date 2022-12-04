defmodule PhoenixLiveDrawWeb.RoomLive.SimulatorComponent do
  use PhoenixLiveDrawWeb, :live_component

  alias PhoenixLiveDraw.Game.{RoomServer, State}

  def render(assigns) do
    ~H"""
    <div class="text-center mt-4">
      State:<br>

      <.button phx-click="change_state" value="stopped" phx-target={@myself}>
        stopped
      </.button>
      <.button phx-click="change_state" value="drawing" phx-target={@myself}>
        drawing
      </.button>
      <.button phx-click="change_state" value="post_round_no_hits" phx-target={@myself}>
        post round (no hits)
      </.button>
      <.button phx-click="change_state" value="post_round_some_hits" phx-target={@myself}>
        post round (some hits)
      </.button>
      <.button phx-click="change_state" value="post_round_all_hit" phx-target={@myself}>
        post round (all hit)
      </.button>

      <br><br>
      Round player:<br>
      <%= for {_, player} <- @room.players do %>
        <.button phx-click="change_round_player" value={player.id} phx-target={@myself}>
          <%= player.name %>
        </.button>
      <% end %>
    </div>
    """
  end

  def handle_event("change_state", %{"value" => state}, socket) do
    new_state = generate_state(state)
    RoomServer.update(socket.assigns.room.id, %{state: new_state})
    {:noreply, socket}
  end

  def handle_event("change_round_player", %{"value" => player_id}, socket) do
    player = Map.get(socket.assigns.room.players, player_id)
    RoomServer.update(socket.assigns.room.id, %{round_player: player})
    {:noreply, socket}
  end

  defp generate_state("stopped"), do: %State.Stopped{}

  defp generate_state("drawing") do
    %State.Drawing{
      word: "cat",
      expires_at: from_now(60, :second),
      points_earned: %{}
    }
  end

  defp generate_state("post_round_no_hits"),
    do: %State.PostRound{outcome: :no_hits, word_was: "cat", expires_at: from_now(10, :second)}

  defp generate_state("post_round_some_hits"),
    do: %State.PostRound{outcome: :some_hits, word_was: "cat", expires_at: from_now(10, :second)}

  defp generate_state("post_round_all_hit"),
    do: %State.PostRound{outcome: :all_hit, word_was: "cat", expires_at: from_now(10, :second)}

  defp from_now(time, unit), do: DateTime.utc_now() |> DateTime.add(time, unit)
end
