defmodule PhoenixLiveDraw.Game.State.Drawing do
  alias PhoenixLiveDraw.Game.{Player, PubSub, Room, State}

  defstruct [:word, :points_earned, :expires_at]

  @type t :: %__MODULE__{
          word: String.t(),
          expires_at: DateTime.t(),

          # A map containing the points earned by players during the current round (both the
          # drawer and the guessers). The points are transferred to the player structs when the
          # round finishes successfully.
          points_earned: %{Player.id() => non_neg_integer()}
        }

  def new do
    %__MODULE__{
      word: "cat",
      expires_at: DateTime.utc_now() |> DateTime.add(60, :second),
      points_earned: %{}
    }
  end

  @behaviour State

  @impl true
  def handle_tick(room) do
    if State.expired?(room.state) do
      {:ok, end_round(room)}
    else
      {:ok, room}
    end
  end

  @impl true
  def handle_command(room, player_id, {:draw, drawing_path}) do
    if player_id == room.round_player.id do
      PubSub.room_broadcast(room.id, {:draw, drawing_path})
    end

    {:ok, nil, room}
  end

  def handle_command(room, _, _), do: {:ok, nil, room}

  @impl true
  # Drawer can't chat
  def handle_message(%Room{round_player: %{id: drawer_id}} = room, drawer_id, _) do
    {:ok, nil, room}
  end

  # Player hit the word
  def handle_message(
        %Room{state: %State.Drawing{word: word, points_earned: points_earned}} = room,
        player_id,
        msg
      )
      when msg == word do
    {reply, room} =
      if Map.has_key?(points_earned, player_id) do
        {nil, room}
      else
        player = room.players[player_id]
        Room.broadcast_system_message(room, "#{player.name} hit the answer")

        updated_room =
          room
          |> give_points(player_id)
          |> end_round_if_all_hit()

        {:correct, updated_room}
      end

    {:ok, reply, room}
  end

  # No guess
  def handle_message(room, player_id, msg) do
    Room.broadcast_player_message(room, player_id, msg)
    {:ok, nil, room}
  end

  defp give_points(room, player_id) do
    drawer_id = room.round_player.id

    updated_points =
      room.state.points_earned
      |> give_drawer_points(drawer_id)
      |> give_guesser_points(player_id)

    put_in(room.state.points_earned, updated_points)
  end

  defp give_drawer_points(points_map, drawer_id) do
    Map.update(points_map, drawer_id, 10, &(&1 + 2))
  end

  defp give_guesser_points(points_map, guesser_id) do
    Map.put(points_map, guesser_id, 10 - map_size(points_map))
  end

  defp end_round_if_all_hit(room) do
    if all_hit?(room) do
      end_round(room)
    else
      room
    end
  end

  defp end_round(room) do
    room
    |> persist_points()
    |> Map.put(:state, generate_post_round(room))
  end

  defp persist_points(room) do
    points_earned = room.state.points_earned

    updated_players =
      room.players
      |> Enum.map(fn {id, player} ->
        {id, %{player | points: player.points + Map.get(points_earned, id, 0)}}
      end)
      |> Enum.into(%{})

    %{room | players: updated_players}
  end

  defp generate_post_round(room) do
    outcome =
      cond do
        all_hit?(room) -> :all_hit
        some_hit?(room) -> :some_hits
        true -> :no_guesses
      end

    State.PostRound.new(outcome: outcome, word_was: room.state.word)
  end

  defp all_hit?(room), do: map_size(room.state.points_earned) == map_size(room.players)

  defp some_hit?(room), do: map_size(room.state.points_earned) > 0
end
