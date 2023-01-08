defmodule PhoenixLiveDraw.Game.PlayerMessage do
  alias PhoenixLiveDraw.Game.Player

  defstruct [:id, :player_id, :name, :body]

  @type t :: %__MODULE__{
          id: id(),
          player_id: Player.id(),
          name: String.t(),
          body: String.t()
        }

  @type id :: String.t()

  @spec new(Keyword.t() | Map.t()) :: t()
  def new(data) do
    data
    |> Enum.into(%{})
    |> Map.put(:id, Ecto.UUID.generate())
    |> then(&struct(__MODULE__, &1))
  end
end
