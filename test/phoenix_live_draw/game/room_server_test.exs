defmodule PhoenixLiveDraw.Game.RoomServerTest do
  use PhoenixLiveDraw.GameCase, async: true

  alias PhoenixLiveDraw.Game
  alias PhoenixLiveDraw.Game.{Player, PubSub, Room, RoomServer, State}

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

  describe "send_command/3" do
    defmodule SendCommandTestState do
      defstruct [:foo]

      @behaviour PhoenixLiveDraw.Game.State

      @impl true
      def handle_command(room, _player_id, :foo) do
        {:ok, "foo!", %{room | state: %{room.state | foo: "foo"}}}
      end

      def handle_command(room, _player_id, :bar) do
        {:ok, nil, %{room | state: %{room.state | foo: "bar"}}}
      end

      @impl true
      def handle_tick(room), do: {:ok, room}

      @impl true
      def handle_message(room, _player_id, _message), do: {:ok, nil, room}
    end

    setup do
      Game.create_room("room_id")

      RoomServer.update("room_id", %{
        players: %{"player_id" => Player.new("player_id", "player name")},
        state: %SendCommandTestState{foo: "foo"}
      })

      # Sleep to prevent from receiving broadcast of room update above
      Process.sleep(100)

      PubSub.room_subscribe("room_id")

      :ok
    end

    test "returns result" do
      assert RoomServer.send_command("room_id", "player_id", :foo) == "foo!"
      assert RoomServer.send_command("room_id", "player_id", :bar) == nil
    end

    test "broadcasts room_updated tuple when the room changes" do
      RoomServer.send_command("room_id", "player_id", :foo)
      refute_receive {:room_updated, _}

      RoomServer.send_command("room_id", "player_id", :bar)
      assert_receive {:room_updated, %{state: %SendCommandTestState{foo: "bar"}}}
    end
  end

  describe "send_message/3" do
    defmodule SendMessageTestState do
      defstruct [:winners]

      @behaviour PhoenixLiveDraw.Game.State

      @impl true
      def handle_message(room, player_id, msg) do
        if msg == "cat" do
          {:ok, "You got the word right: cat",
           %{room | state: %{room.state | winners: [player_id | room.state.winners]}}}
        else
          {:ok, nil, room}
        end
      end

      @impl true
      def handle_tick(room), do: {:ok, room}

      @impl true
      def handle_command(room, _player_id, _command), do: {:ok, nil, room}
    end

    setup do
      Game.create_room("room_id")

      RoomServer.update("room_id", %{
        players: %{"player_id" => Player.new("player_id", "player name")},
        state: %SendMessageTestState{winners: []}
      })

      # Sleep to prevent from receiving broadcast of room update above
      Process.sleep(100)

      PubSub.room_subscribe("room_id")

      :ok
    end

    test "returns result" do
      assert RoomServer.send_message("room_id", "player_id", "dog") == nil

      assert RoomServer.send_message("room_id", "player_id", "cat") ==
               "You got the word right: cat"
    end

    test "broadcasts room_updated tuple when the room changes" do
      RoomServer.send_message("room_id", "player_id", "dog")
      refute_receive {:room_updated, _}

      RoomServer.send_message("room_id", "player_id", "cat")
      assert_receive {:room_updated, %{state: %SendMessageTestState{winners: ["player_id"]}}}
    end
  end

  describe "tick event" do
    defmodule TickTestState do
      defstruct [:value]

      @behaviour PhoenixLiveDraw.Game.State

      @impl true
      def handle_tick(room) do
        new_value = if room.state.value < 3, do: room.state.value + 1, else: 3
        {:ok, %{room | state: %{room.state | value: new_value}}}
      end

      @impl true
      def handle_message(room, _player_id, _message), do: {:ok, nil, room}

      @impl true
      def handle_command(room, _player_id, _command), do: {:ok, nil, room}
    end

    test "broadcasts room_updated tuple when the room changes" do
      Game.create_room("room_id")
      RoomServer.update("room_id", %{state: %TickTestState{value: 0}})

      # Sleep to prevent from receiving broadcast of room update above
      Process.sleep(100)
      PubSub.room_subscribe("room_id")

      Process.sleep(1000)
      assert_receive {:room_updated, %{state: %TickTestState{value: 1}}}

      Process.sleep(1000)
      assert_receive {:room_updated, %{state: %TickTestState{value: 2}}}

      Process.sleep(1000)
      assert_receive {:room_updated, %{state: %TickTestState{value: 3}}}

      Process.sleep(1000)
      refute_receive {:room_updated, %{state: %TickTestState{value: 4}}}
    end
  end
end
