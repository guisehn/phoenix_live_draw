defmodule PhoenixLiveDrawWeb.LayoutComponent do
  use Phoenix.Component

  import PhoenixLiveDrawWeb.ComponentUtils, only: [assign_rest: 2]

  def title(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> nil end)
      |> assign_rest(~w(class))

    ~H"""
    <h1 class={["font-bold text-xl", @class]} {@rest}><%= render_slot(@inner_block) %></h1>
    """
  end

  def subtitle(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> nil end)
      |> assign_rest(~w(class))

    ~H"""
    <p class={["text-gray-500", @class]} {@rest}><%= render_slot(@inner_block) %></p>
    """
  end

  def button(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> nil end)
      |> assign_rest(~w(class))

    ~H"""
    <button
      class={[
        "font-bold py-2 px-4 rounded-full bg-indigo-500 text-white transition hover:bg-indigo-600 active:bg-indigo-800",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
