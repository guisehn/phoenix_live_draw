defmodule PhoenixLiveDraw.Game.Player do
  defstruct [:id, :name, :points, :joined_at]

  @type t :: %__MODULE__{
          id: id(),
          name: String.t(),
          points: non_neg_integer(),
          joined_at: DateTime.t()
        }

  @type id :: String.t()

  def new(id, name) do
    %__MODULE__{
      id: id,
      name: name,
      points: 0,
      joined_at: DateTime.utc_now()
    }
  end
end
