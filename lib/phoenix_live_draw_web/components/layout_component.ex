defmodule PhoenixLiveDrawWeb.LayoutComponent do
  use Phoenix.Component

  def title(assigns) do
    ~H"""
    <h1 class={"font-bold text-xl #{assigns[:class]}"}><%= render_slot(@inner_block) %></h1>
    """
  end

  def subtitle(assigns) do
    ~H"""
    <p class={"text-gray-500 #{assigns[:class]}"}><%= render_slot(@inner_block) %></p>
    """
  end

  def button(assigns) do
    class = [
      "font-bold py-2 px-4 rounded bg-indigo-500 text-white transition hover:bg-indigo-600 active:bg-indigo-800",
      assigns[:class]
    ]

    ~H"""
    <button {assigns_to_attributes(assigns, [:class])} class={class}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
