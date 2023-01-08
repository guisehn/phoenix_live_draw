defmodule PhoenixLiveDraw.Game.WordsTest do
  use ExUnit.Case, async: true

  alias PhoenixLiveDraw.Game.Words

  test "sample/0" do
    word = Words.sample()
    assert is_binary(word)
  end

  test "size/0" do
    size = Words.size()
    assert is_integer(size)
  end
end
