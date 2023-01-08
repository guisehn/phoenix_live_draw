defmodule PhoenixLiveDraw.Game.StateTest do
  use ExUnit.Case, async: true

  alias PhoenixLiveDraw.Game.State

  describe "expired?/1" do
    test "returns true when expires_at is in the past" do
      future = DateTime.utc_now() |> DateTime.add(-1, :second)
      state = %{expires_at: future}
      assert State.expired?(state)
    end

    test "returns false when expires_at is in the future" do
      future = DateTime.utc_now() |> DateTime.add(1, :second)
      state = %{expires_at: future}
      refute State.expired?(state)
    end
  end
end
