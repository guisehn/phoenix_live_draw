defmodule PhoenixLiveDraw.Game.Room do
  alias PhoenixLiveDraw.Game.{Player, PlayerMessage, PubSub, State, SystemMessage}

  defstruct [:id, :players, :round_player, :state, :destroy_when_empty?]

  @type t :: %__MODULE__{
          id: id(),
          players: %{Player.id() => Player.t()},
          state: state(),
          destroy_when_empty?: boolean(),

          # Who is drawing now
          round_player: Player.t() | nil
        }

  @type id :: String.t()

  @type state :: State.Stopped.t() | State.Drawing.t() | State.PostRound.t()

  @spec new(id) :: t
  def new(id) do
    %__MODULE__{
      id: id,
      players: %{},
      state: %State.Stopped{},
      round_player: nil,
      destroy_when_empty?: get_config(:destroy_when_empty?)
    }
  end

  defp get_config(key),
    do: Application.fetch_env!(:phoenix_live_draw, __MODULE__) |> Keyword.get(key)

  @doc "Stops the game, resetting the room state"
  @spec stop_game(t) :: t
  def stop_game(room) do
    players =
      room.players
      |> Enum.map(fn {id, player} -> {id, %{player | points: 0}} end)
      |> Enum.into(%{})

    %{room | players: players, round_player: nil, state: %State.Stopped{}}
  end

  @doc """
  Updates the list of players of the room, based on the payload of a presence_diff event
  from Phoenix.Presence
  """
  @spec update_players(t, %{joins: map, leaves: map}) :: t
  def update_players(room, %{joins: joins, leaves: leaves}) do
    updated_players =
      room.players
      |> handle_leaves(leaves)
      |> handle_joins(joins)

    %{room | players: updated_players}
  end

  defp handle_leaves(players, leaves) do
    Enum.reduce(leaves, players, fn {user_id, _}, players ->
      Map.delete(players, user_id)
    end)
  end

  defp handle_joins(players, joins) do
    Enum.reduce(joins, players, fn {user_id, %{metas: [meta | _]}}, players ->
      Map.put(players, user_id, Player.new(user_id, meta.name))
    end)
  end

  @doc "Returns a map with a diff between two room structs"
  @spec diff(t, t) :: map
  def diff(room, room), do: %{}

  def diff(new_room, old_room) do
    new_room = Map.from_struct(new_room)
    old_room = Map.from_struct(old_room)

    Enum.reduce(new_room, %{}, fn {key, value}, diff ->
      if new_room[key] != old_room[key] do
        Map.put(diff, key, value)
      else
        diff
      end
    end)
  end

  @doc "Builds the next round of the game"
  def build_next_round(room) do
    next_player = next_round_player(room)
    next_state = State.Drawing.new()
    %{room | round_player: next_player, state: next_state}
  end

  @doc "Broadcasts a system message announcing the next round"
  def announce_round_update(%__MODULE__{state: %State.Drawing{}, round_player: player} = room) do
    broadcast_system_message(room, "#{player.name} is drawing now")
    room
  end

  def announce_round_update(room), do: room

  @doc "Fetches the next player to draw"
  def next_round_player(room) do
    joined_at = if room.round_player, do: room.round_player.joined_at
    players = room.players |> Map.values() |> Enum.sort_by(& &1.joined_at)
    next_player = Enum.find(players, &(&1.joined_at > joined_at))
    next_player || List.first(players)
  end

  @doc "Broadcasts a message from a player to all other players of the room"
  def broadcast_player_message(room, player_id, message) do
    player = room.players[player_id]
    message = PlayerMessage.new(player_id: player_id, name: player.name, body: message)
    PubSub.room_broadcast(room.id, {:new_message, message})
  end

  @doc "Broadcasts a system message to all players of the room"
  def broadcast_system_message(room, message) do
    message = SystemMessage.new(body: message)
    PubSub.room_broadcast(room.id, {:new_message, message})
  end
end
