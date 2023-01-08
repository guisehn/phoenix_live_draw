defmodule PhoenixLiveDraw.Game.State.DrawingTest do
  use ExUnit.Case, async: true

  alias PhoenixLiveDraw.Game.{Player, PlayerMessage, PubSub, Room, State}

  defp room_in_drawing_state(state_data \\ %{}) do
    room = Room.new("room_id")

    players = %{
      "player1_id" => Player.new("player1_id", "player 1"),
      "player2_id" => Player.new("player2_id", "player 2"),
      "player3_id" => Player.new("player3_id", "player 3"),
      "player4_id" => Player.new("player3_id", "player 4")
    }

    state = %{State.Drawing.new() | word: "cat"} |> Map.merge(state_data)

    %{room | state: state, players: players, round_player: players["player1_id"]}
  end

  describe "handle_tick/1" do
    test "returns unmodified room when round is still active" do
      room = room_in_drawing_state()
      assert State.Drawing.handle_tick(room) == {:ok, room}
    end

    test "ends round when it expires with no hits" do
      room = room_in_drawing_state(%{expires_at: DateTime.utc_now() |> DateTime.add(-1, :second)})

      {:ok, room} = State.Drawing.handle_tick(room)

      assert room.state.__struct__ == State.PostRound
      assert %{outcome: :no_hits, word_was: "cat"} = room.state
      assert room.players["player1_id"].points == 0
      assert room.players["player2_id"].points == 0
      assert room.players["player3_id"].points == 0
      assert room.players["player4_id"].points == 0
    end

    test "ends round when it expires with some hits" do
      room =
        room_in_drawing_state(%{
          expires_at: DateTime.utc_now() |> DateTime.add(-1, :second),
          points_earned: %{"player1_id" => 12, "player2_id" => 10, "player3_id" => 9}
        })

      {:ok, room} = State.Drawing.handle_tick(room)

      assert room.state.__struct__ == State.PostRound
      assert %{outcome: :some_hits, word_was: "cat"} = room.state
      assert room.players["player1_id"].points == 12
      assert room.players["player2_id"].points == 10
      assert room.players["player3_id"].points == 9
      assert room.players["player4_id"].points == 0
    end
  end

  describe "handle_command: draw" do
    # TODO: broadcasts drawing
    # TODO: doesn't do anything when player is not the drawer
  end

  describe "handle_message/3" do
    # TODO: doesn't allow drawer to send message
    # TODO: broadcasts message when message is not the answer
    # TODO: doesn't broadcast message when message is the answer
    # TODO: gives point to drawer and guesser (first hit)
    # TODO: gives point to drawer and guesser (second hit)
    # TODO: gives point to drawer and guesser and ends round (everybody hit)
    # TODO: doesn't give duplicate points
  end
end
