defmodule PhoenixLiveDrawWeb.ComponentUtils do
  use Phoenix.Component

  def assign_rest(assigns, exclude \\ []) do
    exclude = Enum.map(exclude, &:"#{&1}")
    assign(assigns, :rest, assigns_to_attributes(assigns, exclude))
  end
end
