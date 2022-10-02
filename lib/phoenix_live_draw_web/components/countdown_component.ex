defmodule PhoenixLiveDrawWeb.CountdownComponent do
  use Phoenix.Component

  def countdown(assigns) do
    ~H"""
    <div
      phx-hook="Countdown"
      phx-update="ignore"
      data-seconds={seconds_left(@until)}
      id={@id}
      class="w-full bg-gray-200 rounded-full h-2.5"
    >
      <div data-bar class="bg-indigo-600 h-2.5 rounded-full"></div>
    </div>
    """
  end

  defp seconds_left(until) do
    now = DateTime.utc_now()
    DateTime.diff(until, now)
  end

  def bottom_countdown(assigns) do
    assigns = assign_new(assigns, :class, fn -> nil end)

    ~H"""
    <div class={"absolute mb-2 bottom-0 left-2 right-2 #{@class}"}>
      <.countdown {assigns} />
    </div>
    """
  end
end
