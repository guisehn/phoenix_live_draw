defmodule PhoenixLiveDraw.Game.State.PostRoundTest do
  use ExUnit.Case, async: true

  alias PhoenixLiveDraw.Game.{Player, PlayerMessage, PubSub, Room, State, SystemMessage}

  defp room_in_post_round_state(state_data \\ %{}) do
    room = Room.new("room_id")

    players = %{
      "player1_id" => Player.new("player1_id", "player 1"),
      "player2_id" => Player.new("player2_id", "player 2"),
      "player3_id" => Player.new("player3_id", "player 3"),
      "player4_id" => Player.new("player3_id", "player 4")
    }

    state = State.PostRound.new(outcome: :some_hits, word_was: "cat") |> Map.merge(state_data)

    %{room | state: state, players: players, round_player: players["player1_id"]}
  end

  describe "handle_tick/1" do
    test "returns unmodified room when round is still active" do
      room = room_in_post_round_state()
      assert State.PostRound.handle_tick(room) == {:ok, room}
    end

    test "moves to next round when it expires" do
      PubSub.room_subscribe("room_id")

      room =
        room_in_post_round_state(%{
          expires_at: DateTime.utc_now() |> DateTime.add(-1, :second)
        })

      {:ok, room} = State.PostRound.handle_tick(room)

      assert %State.Drawing{} = room.state
      assert room.round_player == room.players["player2_id"]

      assert_receive {:new_message,
                      %SystemMessage{
                        body: "player 2 is drawing now"
                      }}
    end
  end

  describe "handle_message/3" do
    setup do
      {:ok, room: room_in_post_round_state()}
    end

    test "returns unmodified room", %{room: room} do
      assert {:ok, nil, ^room} = State.PostRound.handle_message(room, "player1_id", "hello")
    end

    test "broadcasts message", %{room: room} do
      PubSub.room_subscribe("room_id")
      State.PostRound.handle_message(room, "player1_id", "hello")

      assert_receive {:new_message,
                      %PlayerMessage{
                        player_id: "player1_id",
                        name: "player 1",
                        body: "hello"
                      }}
    end
  end
end
