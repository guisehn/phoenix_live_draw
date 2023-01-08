defmodule PhoenixLiveDraw.Game.State.PostRound do
  alias PhoenixLiveDraw.Game.{Room, State}

  defstruct [:outcome, :word_was, :expires_at]

  @type t :: %__MODULE__{
          outcome: outcome(),
          word_was: String.t(),
          expires_at: DateTime.t()
        }

  @type outcome :: :no_hits | :some_hits | :all_hit

  @spec new(Keyword.t() | Map.t()) :: t()
  def new(data) do
    data
    |> Enum.into(%{})
    |> Map.put(:expires_at, DateTime.utc_now() |> DateTime.add(5, :second))
    |> then(&struct(__MODULE__, &1))
  end

  @behaviour State

  @impl true
  def handle_tick(room) do
    if State.expired?(room.state) do
      {:ok, Room.build_next_round(room) |> Room.announce_round_update()}
    else
      {:ok, room}
    end
  end

  @impl true
  def handle_command(room, _, _), do: {:ok, nil, room}

  @impl true
  def handle_message(room, player_id, message) do
    Room.broadcast_player_message(room, player_id, message)
    {:ok, nil, room}
  end
end
