defmodule PhoenixLiveDrawWeb.RoomLive.Stage.PostRoundComponent do
  use PhoenixLiveDrawWeb, :live_component

  alias PhoenixLiveDraw.Game.Room
  alias PhoenixLiveDraw.Game.State.PostRound

  import PhoenixLiveDrawWeb.CountdownComponent

  def render(%{room: %Room{state: %PostRound{outcome: :no_hits}}} = assigns) do
    ~H"""
    <main>
      <.title>Nobody hit the answer</.title>
      <.post_round_countdown room={@room} />
    </main>
    """
  end

  def render(%{room: %Room{state: %PostRound{outcome: :some_hits, word_was: word_was}}} = assigns) do
    ~H"""
    <main>
      <.title>Some people hit the answer!</.title>
      <.subtitle>The word was: <%= word_was %></.subtitle>
      <.post_round_countdown room={@room} />
    </main>
    """
  end

  def render(%{room: %Room{state: %PostRound{outcome: :all_hit, word_was: word_was}}} = assigns) do
    ~H"""
    <main>
      <.title>Everybody hit the answer!</.title>
      <.subtitle>The word was: <%= word_was %></.subtitle>
      <.post_round_countdown room={@room} />
    </main>
    """
  end

  defp post_round_countdown(assigns) do
    ~H"""
    <.bottom_countdown id={"#{@room.state.outcome}_countdown"} until={@room.state.expires_at} />
    """
  end
end
