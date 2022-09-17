defmodule PhoenixLiveDraw.Game.Room do
  alias PhoenixLiveDraw.Game.Player

  defstruct [:id, :players, :round_player, :state]

  @type t :: %__MODULE__{
          id: id(),
          players: %{Player.id() => Player.t()},
          state: state,

          # Who is drawing now
          round_player: Player.t() | nil
        }

  @type id :: String.t()

  # TODO: define the actual states once we have them
  @type state :: any
end
