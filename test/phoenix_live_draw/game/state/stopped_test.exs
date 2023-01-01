defmodule PhoenixLiveDraw.Game.State.StoppedTest do
  use ExUnit.Case, async: true

  alias PhoenixLiveDraw.Game.{Player, PlayerMessage, PubSub, Room, State}

  describe "handle_tick/1" do
    test "returns unmodified room" do
      room = %{Room.new("room_id") | state: %State.Stopped{}}
      assert State.Stopped.handle_tick(room) == {:ok, room}
    end
  end

  describe "handle_message/3" do
    setup do
      room = %{
        Room.new("room_id")
        | state: %State.Stopped{},
          players: %{"player_id" => Player.new("player_id", "player name")}
      }

      {:ok, room: room}
    end

    test "returns unmodified room", %{room: room} do
      assert {:ok, nil, ^room} = State.Stopped.handle_message(room, "player_id", "hello")
    end

    test "broadcasts message", %{room: room} do
      PubSub.room_subscribe("room_id")
      State.Stopped.handle_message(room, "player_id", "hello")

      assert_receive {:new_message,
                      %PlayerMessage{
                        player_id: "player_id",
                        name: "player name",
                        body: "hello"
                      }}
    end
  end

  describe "handle_command: start" do
    test "starts game when there is at least two players" do
      room = %{
        Room.new("room_id")
        | state: %State.Stopped{},
          players: %{
            "player1_id" => Player.new("player1_id", "player 1"),
            "player2_id" => Player.new("player2_id", "player 2")
          }
      }

      assert {:ok, nil, updated_room} = State.Stopped.handle_command(room, "player1_id", :start)
      assert %State.Drawing{} = updated_room.state
      assert updated_room.round_player == room.players["player1_id"]
    end

    test "keeps game stopped if there is less than two players" do
      room = %{
        Room.new("room_id")
        | state: %State.Stopped{},
          players: %{"player_id" => Player.new("player_id", "player name")}
      }

      assert State.Stopped.handle_command(room, "player_id", :start) == {:ok, nil, room}
    end
  end
end
