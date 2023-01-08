defmodule PhoenixLiveDraw.Game.SystemMessage do
  defstruct [:id, :body]

  @type t :: %__MODULE__{
          id: id(),
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
