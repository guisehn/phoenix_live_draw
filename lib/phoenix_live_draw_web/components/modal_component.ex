defmodule PhoenixLiveDrawWeb.ModalComponent do
  use Phoenix.Component

  def modal(assigns) do
    ~H"""
    <div data-modal class="bg-gray-500/40 backdrop-blur-sm w-full h-full fixed top-0 left-0">
      <div class="flex min-h-full items-end justify-center text-center items-center">
        <div class="rounded-lg bg-white text-left shadow-xl relative w-full max-w-sm p-8">
          <div class="mb-4">
            <%= render_slot(@header) %>
          </div>

          <%= render_slot(@content) %>
        </div>
      </div>
    </div>
    """
  end

  def modal_title(assigns) do
    ~H"""
    <div class="text-lg font-medium leading-6 text-gray-900">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
