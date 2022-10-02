defmodule PhoenixLiveDrawWeb.RoomLive.StageComponent do
  use PhoenixLiveDrawWeb, :component

  alias PhoenixLiveDraw.Game.State
  alias PhoenixLiveDrawWeb.RoomLive.Stage

  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-full relative items-center justify-center text-center">
      <.live_component
        module={component_from_state(@room.state)}
        room={@room}
        player_id={@player_id}
        id={"stage_#{component_from_state(@room.state)}"}
      />
    </div>
    """
  end

  defp component_from_state(%State.Stopped{}), do: Stage.StoppedComponent
  defp component_from_state(%State.Drawing{}), do: Stage.DrawingComponent
  defp component_from_state(%State.PostRound{}), do: Stage.PostRoundComponent
end
