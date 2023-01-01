defmodule PhoenixLiveDraw.Game.RoomServerTest do
  # use ExUnit.Case, async: true

  use PhoenixLiveDraw.GameCase, async: true

  alias PhoenixLiveDraw.Game
  alias PhoenixLiveDraw.Game.{Player, Room, RoomServer, State}

  describe "join/3" do
    setup do
      Game.create_room("room_id")
      :ok
    end

    test "returns {:ok, room}" do
      assert {:ok, room} = RoomServer.join("room_id", "player_id", "player name")

      assert %Room{
               id: "room_id",
               players: %{},
               round_player: nil,
               state: %State.Stopped{}
             } = room
    end

    test "broadcasts room_updated tuple with room diff containing new player" do
      RoomServer.join("room_id", "player_id", "player name")

      assert_receive {:room_updated,
                      %{
                        players: %{
                          "player_id" => %Player{
                            id: "player_id",
                            joined_at: _,
                            name: "player name",
                            points: 0
                          }
                        }
                      }}
    end
  end
end
