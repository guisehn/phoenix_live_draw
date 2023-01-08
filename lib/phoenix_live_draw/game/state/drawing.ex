defmodule PhoenixLiveDraw.Game.State.Drawing do
  alias PhoenixLiveDraw.Game.{Player, Room}

  defstruct [:word, :points_earned, :expires_at]

  @type t :: %__MODULE__{
          word: String.t(),
          expires_at: DateTime.t(),

          # A map containing the points earned by players during the current round (both the
          # drawer and the guessers). The points are transferred to the player structs when the
          # round finishes successfully.
          points_earned: %{Player.id() => non_neg_integer()}
        }

  def new do
    %__MODULE__{
      word: "cat",
      expires_at: DateTime.utc_now() |> DateTime.add(60, :second),
      points_earned: %{}
    }
  end

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
