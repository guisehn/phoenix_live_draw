defmodule PhoenixLiveDrawWeb.RoomLive.StageComponent do
  use PhoenixLiveDrawWeb, :component

  alias PhoenixLiveDraw.Game.State
  alias PhoenixLiveDrawWeb.RoomLive.Stage

  def render(%{room: room} = assigns) do
    component =
      case room.state do
        %State.Stopped{} -> Stage.StoppedComponent
        %State.Drawing{} -> Stage.DrawingComponent
        %State.PostRound{} -> Stage.PostRoundComponent
      end

    ~H"""
    <div class="flex flex-col h-full relative items-center justify-center text-center">
      <.live_component
        module={component}
        room={@room}
        player_id={@player_id}
        id={"stage_#{component}"}
      />
    </div>
    """
  end
end
