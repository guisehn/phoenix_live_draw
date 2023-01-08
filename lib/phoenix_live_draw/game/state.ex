defmodule PhoenixLiveDraw.Game.State do
  @moduledoc """
  Represents a game state.

  Each state has its own logic for dealing with events such as tick, player message,
  or player command.
  """

  alias PhoenixLiveDraw.Game.{Player, Room}

  @type message :: String.t()
  @type command :: any()

  @doc "Code to execute every second"
  @callback handle_tick(Room.t()) :: {:ok, Room.t()}

  @doc "Code to execute when player sends a message"
  @callback handle_message(Room.t(), Player.id(), message) :: {:ok, message | nil, Room.t()}

  @doc "Code to execute when player sends a command"
  @callback handle_command(Room.t(), Player.id(), command) :: {:ok, message | nil, Room.t()}

  def expired?(%{expires_at: expires_at}, now \\ DateTime.utc_now()) do
    DateTime.compare(now, expires_at) == :gt
  end
end
