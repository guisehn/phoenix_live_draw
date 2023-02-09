defmodule PhoenixLiveDraw.Game.State.DrawingTest do
  use ExUnit.Case, async: true

  alias PhoenixLiveDraw.Game.{Player, PlayerMessage, PubSub, Room, State, SystemMessage}

  defp room_in_drawing_state(state_data \\ %{}) do
    room = Room.new("room_id")

    players = %{
      "player1_id" => Player.new("player1_id", "player 1"),
      "player2_id" => Player.new("player2_id", "player 2"),
      "player3_id" => Player.new("player3_id", "player 3"),
      "player4_id" => Player.new("player3_id", "player 4")
    }

    state = State.Drawing.new("cat") |> Map.merge(state_data)

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

      assert %State.PostRound{outcome: :no_hits, word_was: "cat"} = room.state
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

      assert %State.PostRound{outcome: :some_hits, word_was: "cat"} = room.state
      assert room.players["player1_id"].points == 12
      assert room.players["player2_id"].points == 10
      assert room.players["player3_id"].points == 9
      assert room.players["player4_id"].points == 0
    end
  end

  describe "handle_command: {:draw, path}" do
    test "broadcasts drawing of round player" do
      PubSub.room_subscribe("room_id")

      room = room_in_drawing_state()

      assert {:ok, nil, ^room} =
               State.Drawing.handle_command(
                 room,
                 "player1_id",
                 {:draw, [%{x: 3, y: 2}, %{x: 4, y: 1}]}
               )

      assert_receive {:draw, [%{x: 3, y: 2}, %{x: 4, y: 1}]}
    end

    test "ignores when player issuing command is not the round player" do
      PubSub.room_subscribe("room_id")

      room = room_in_drawing_state()

      assert {:ok, nil, ^room} =
               State.Drawing.handle_command(
                 room,
                 "player2_id",
                 {:draw, [%{x: 3, y: 2}, %{x: 4, y: 1}]}
               )

      refute_receive {:draw, _}
    end
  end

  describe "handle_message/3" do
    test "doesn't allow drawer to send message" do
      room = room_in_drawing_state()

      PubSub.room_subscribe("room_id")

      assert {:ok, nil, ^room} = State.Drawing.handle_message(room, "player1_id", "hello")

      refute_receive {:new_message, _}
    end

    test "broadcasts message when message is not the answer" do
      room = room_in_drawing_state()

      PubSub.room_subscribe("room_id")

      assert {:ok, nil, ^room} = State.Drawing.handle_message(room, "player2_id", "hello")

      assert_receive {:new_message,
                      %PlayerMessage{
                        player_id: "player2_id",
                        name: "player 2",
                        body: "hello"
                      }}
    end

    test "doesn't broadcast player message when message is the answer" do
      room = room_in_drawing_state()

      PubSub.room_subscribe("room_id")

      assert {:ok, :correct, _room} = State.Drawing.handle_message(room, "player2_id", "cat")

      refute_receive {:new_message, %PlayerMessage{}}
    end

    test "announces player hit when message is the answer" do
      room = room_in_drawing_state()

      PubSub.room_subscribe("room_id")

      assert {:ok, :correct, _room} = State.Drawing.handle_message(room, "player2_id", "cat")

      assert_receive {:new_message, %SystemMessage{body: "player 2 hit the answer"}}
    end

    test "checks answer as case insensitive" do
      room = room_in_drawing_state()

      PubSub.room_subscribe("room_id")

      assert {:ok, :correct, _room} = State.Drawing.handle_message(room, "player2_id", "CAT")

      assert_receive {:new_message, %SystemMessage{body: "player 2 hit the answer"}}
    end

    test "gives point to drawer and guesser (first hit)" do
      room = room_in_drawing_state()

      PubSub.room_subscribe("room_id")

      assert {:ok, :correct, room} = State.Drawing.handle_message(room, "player2_id", "cat")

      assert room.state.points_earned["player1_id"] == 10
      assert room.state.points_earned["player2_id"] == 9
      refute Map.has_key?(room.state.points_earned, "player3_id")
      refute Map.has_key?(room.state.points_earned, "player4_id")

      assert room.players["player1_id"].points == 0
      assert room.players["player2_id"].points == 0
      assert room.players["player3_id"].points == 0
      assert room.players["player4_id"].points == 0
    end

    test "gives point to drawer and guesser (second hit)" do
      room = room_in_drawing_state()

      PubSub.room_subscribe("room_id")

      assert {:ok, :correct, room} = State.Drawing.handle_message(room, "player2_id", "cat")
      assert {:ok, :correct, room} = State.Drawing.handle_message(room, "player3_id", "cat")

      assert room.state.points_earned["player1_id"] == 10 + 2
      assert room.state.points_earned["player2_id"] == 9
      assert room.state.points_earned["player3_id"] == 8
      refute Map.has_key?(room.state.points_earned, "player4_id")

      assert room.players["player1_id"].points == 0
      assert room.players["player2_id"].points == 0
      assert room.players["player3_id"].points == 0
      assert room.players["player4_id"].points == 0
    end

    test "gives point to drawer and guesser and ends round when everybody hit" do
      room = room_in_drawing_state()

      PubSub.room_subscribe("room_id")

      assert {:ok, :correct, room} = State.Drawing.handle_message(room, "player2_id", "cat")
      assert {:ok, :correct, room} = State.Drawing.handle_message(room, "player3_id", "cat")
      assert {:ok, :correct, room} = State.Drawing.handle_message(room, "player4_id", "cat")

      assert %State.PostRound{outcome: :all_hit, word_was: "cat"} = room.state
      assert room.players["player1_id"].points == 10 + 2 + 2
      assert room.players["player2_id"].points == 9
      assert room.players["player3_id"].points == 8
      assert room.players["player4_id"].points == 7
    end

    test "ignores duplicate correct answer" do
      room = room_in_drawing_state()

      PubSub.room_subscribe("room_id")

      assert {:ok, :correct, room} = State.Drawing.handle_message(room, "player2_id", "cat")

      refute_receive {:new_message, %PlayerMessage{}}
      assert_receive {:new_message, %SystemMessage{body: "player 2 hit the answer"}}

      assert room.state.points_earned["player1_id"] == 10
      assert room.state.points_earned["player2_id"] == 9

      assert {:ok, nil, room} = State.Drawing.handle_message(room, "player2_id", "cat")

      refute_receive {:new_message, %PlayerMessage{}}
      refute_receive {:new_message, %SystemMessage{}}

      assert room.state.points_earned["player1_id"] == 10
      assert room.state.points_earned["player2_id"] == 9
    end
  end
end
