defmodule PhoenixLiveDraw.GameCase do
  @moduledoc """
  This module defines the test case to be used by tests that need
  access to global game state processes.

  Each test case gets brand new processes, with an empty server state.
  """

  use ExUnit.CaseTemplate

  setup do
    PhoenixLiveDraw.Game.RoomServer.setup_local_process_prefix()
    PhoenixLiveDraw.Game.RoomSupervisor.setup_local_process_ref()

    PhoenixLiveDraw.Game.RoomSupervisor.start_link(:ok)

    :ok
  end
end
