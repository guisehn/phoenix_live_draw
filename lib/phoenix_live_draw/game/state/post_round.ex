defmodule PhoenixLiveDraw.Game.State.PostRound do
  defstruct [:outcome, :word_was, :expires_at]

  @type t :: %__MODULE__{
          outcome: outcome(),
          word_was: String.t(),
          expires_at: DateTime.t()
        }

  @type outcome :: :no_hits | :some_hits | :all_hit
end
