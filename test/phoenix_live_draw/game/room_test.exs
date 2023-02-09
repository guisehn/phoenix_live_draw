defmodule PhoenixLiveDraw.Game.RoomTest do
  use ExUnit.Case, async: true

  alias PhoenixLiveDraw.Game.{Room, Player, PlayerMessage, PubSub, State}

  test "new/1" do
    room = Room.new("cb594c62")

    assert %Room{
             id: "cb594c62",
             players: %{},
             state: %State.Stopped{},
             round_player: nil,
             destroy_when_empty?: false
           } = room
  end

  describe "stop_game/1" do
    test "resets the game state" do
      players = %{
        "901e6fad" => Player.new("901e6fad", "foo") |> Map.put(:points, 20),
        "5b2917a5" => Player.new("5b2917a5", "bar") |> Map.put(:points, 10)
      }

      room = %Room{
        id: "cb594c62",
        players: players,
        state: %State.Drawing{word: "cat"},
        round_player: players["901e6fad"]
      }

      updated_room = Room.stop_game(room)

      assert %Room{
               state: %State.Stopped{},
               round_player: nil
             } = updated_room

      for {_id, player} <- updated_room.players do
        assert player.points == 0
      end
    end
  end

  describe "update_players/2" do
    test "adds and removes players using payload from Phoenix.Presence" do
      room = %Room{
        id: "cb594c62",
        players: %{
          "901e6fad" => Player.new("901e6fad", "foo") |> Map.put(:points, 20),
          "5b2917a5" => Player.new("5b2917a5", "bar") |> Map.put(:points, 10)
        }
      }

      presence_diff = %{
        joins: %{
          "7c5b82f5" => %{
            metas: [%{name: "gui", phx_ref: "Fy23Y-kQWNB_cQAC"}]
          }
        },
        leaves: %{
          "901e6fad" => %{
            metas: [%{name: "foo", phx_ref: "Fy23kt0PGyh_cQKD"}]
          }
        }
      }

      updated_room = Room.update_players(room, presence_diff)

      refute Map.has_key?(updated_room.players, "901e6fad")

      assert %Player{id: "5b2917a5", name: "bar", points: 10} = updated_room.players["5b2917a5"]
      assert %Player{id: "7c5b82f5", name: "gui", points: 0} = updated_room.players["7c5b82f5"]
    end
  end

  describe "next_round_player/1" do
    test "returns first player when there is no round player" do
      players = %{
        "foo" => Player.new("foo", "foo"),
        "bar" => Player.new("bar", "bar")
      }

      room = %{Room.new("room_id") | players: players}

      assert Room.next_round_player(room) == players["foo"]
    end

    test "returns next player" do
      players = %{
        "foo" => Player.new("foo", "foo"),
        "bar" => Player.new("bar", "bar")
      }

      room = %{Room.new("room_id") | players: players, round_player: players["foo"]}

      assert Room.next_round_player(room) == players["bar"]
    end

    test "resets to first player after the last one" do
      players = %{
        "foo" => Player.new("foo", "foo"),
        "bar" => Player.new("bar", "bar")
      }

      room = %{Room.new("room_id") | players: players, round_player: players["bar"]}

      assert Room.next_round_player(room) == players["foo"]
    end
  end

  describe "build_next_round/1" do
    test "builds the next drawing round" do
      players = %{
        "foo" => Player.new("foo", "foo"),
        "bar" => Player.new("bar", "bar")
      }

      room = %{Room.new("room_id") | players: players} |> Room.build_next_round()

      assert room.round_player == players["foo"]
      assert %State.Drawing{} = room.state
    end

    test "clears drawing" do
      players = %{
        "foo" => Player.new("foo", "foo"),
        "bar" => Player.new("bar", "bar")
      }

      room = %{Room.new("room_id") | players: players} |> Room.build_next_round()

      Room.draw(room, [%{x: 5, y: 5}])
      Room.build_next_round(room)

      assert Room.get_drawing(room) == []
    end
  end

  describe "broadcast_player_message/3" do
    test "broadcasts message" do
      players = %{
        "player_id" => Player.new("player_id", "player name")
      }

      room = %{Room.new("room_id") | players: players}

      PubSub.room_subscribe("room_id")

      Room.broadcast_player_message(room, "player_id", "hello")

      assert_receive {:new_message,
                      %PlayerMessage{player_id: "player_id", name: "player name", body: "hello"}}
    end
  end

  describe "diff/2" do
    test "returns empty map when rooms are the same" do
      room = Room.new("room_id")
      assert Room.diff(room, room) == %{}
    end

    test "returns diff between new and old room" do
      old_room = Room.new("room_id")

      new_players = %{"player_id" => Player.new("foo", "Foo")}
      new_room = %{old_room | players: new_players}

      assert Room.diff(new_room, old_room) == %{players: new_players}
    end
  end

  describe "draw/2" do
    test "broadcasts drawing" do
      room = Room.new("room_id")

      PubSub.room_subscribe("room_id")

      Room.draw(room, [%{x: 3, y: 2}, %{x: 4, y: 1}])

      assert_receive {:draw, [%{x: 3, y: 2}, %{x: 4, y: 1}]}
    end
  end

  describe "get_drawing/1" do
    test "gets current drawing" do
      room = Room.new("room_id")

      Room.draw(room, [%{x: 3, y: 2}, %{x: 4, y: 1}])
      Room.draw(room, [%{x: 6, y: 4}])

      drawing = Room.get_drawing(room)
      assert drawing == [[%{x: 3, y: 2}, %{x: 4, y: 1}], [%{x: 6, y: 4}]]
    end
  end

  describe "clear_drawing/1" do
    test "clears drawing" do
      room = Room.new("room_id")

      Room.draw(room, [%{x: 3, y: 2}, %{x: 4, y: 1}])
      Room.draw(room, [%{x: 6, y: 4}])
      Room.clear_drawing(room)

      drawing = Room.get_drawing(room)
      assert drawing == []
    end
  end
end
