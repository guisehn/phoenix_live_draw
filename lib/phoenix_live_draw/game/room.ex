defmodule PhoenixLiveDraw.Game.Room do
  alias PhoenixLiveDraw.Game.{Player, State}

  defstruct [:id, :players, :round_player, :state]

  @type t :: %__MODULE__{
          id: id(),
          players: %{Player.id() => Player.t()},
          state: state(),

          # Who is drawing now
          round_player: Player.t() | nil
        }

  @type id :: String.t()

  @type state :: State.Stopped.t() | State.Drawing.t() | State.PostRound.t()
end
