defmodule PhoenixLiveDraw.Game.State.PostRound do
  alias PhoenixLiveDraw.Game.Room

  defstruct [:outcome, :word_was, :expires_at]

  @type t :: %__MODULE__{
          outcome: outcome(),
          word_was: String.t(),
          expires_at: DateTime.t()
        }

  @type outcome :: :no_hits | :some_hits | :all_hit

  @behaviour PhoenixLiveDraw.Game.State

  @impl true
  def handle_tick(room), do: {:ok, room}

  @impl true
  def handle_command(room, _, _), do: {:ok, nil, room}

  @impl true
  def handle_message(room, player_id, message) do
    Room.broadcast_player_message(room, player_id, message)
    {:ok, nil, room}
  end
end
