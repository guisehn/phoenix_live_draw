defmodule PhoenixLiveDraw.Game.RoomTest do
  use ExUnit.Case, async: true

  alias PhoenixLiveDraw.Game.{Room, Player, State}

  test "new/1" do
    room = Room.new("cb594c62")

    assert room == %Room{
             id: "cb594c62",
             players: %{},
             state: %State.Stopped{},
             round_player: nil
           }
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
end
