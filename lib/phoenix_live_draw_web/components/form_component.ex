defmodule PhoenixLiveDrawWeb.FormComponent do
  use Phoenix.Component

  import Phoenix.HTML.Form
  import PhoenixLiveDrawWeb.ComponentUtils, only: [assign_rest: 2]

  def form_group(assigns) do
    ~H"""
    <div class="mb-4">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def form_label(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> nil end)
      |> assign_new(:form, fn -> nil end)
      |> assign_new(:for, fn -> input_id(assigns.form, assigns.field) end)
      |> assign_rest(~w(class form))

    ~H"""
    <label
      class={["block text-gray-700 text-sm mb-2", @class]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  def form_input(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> nil end)
      |> assign_new(:type, fn -> "text" end)
      |> assign_new(:form, fn -> nil end)
      |> assign_new(:name, fn -> input_name(assigns.form, assigns.field) end)
      |> assign_new(:id, fn -> input_id(assigns.form, assigns.field) end)
      |> assign_rest(~w(class form))

    ~H"""
      <input
        class={[
          "appearance-none bg-gray-50 border-gray-300 rounded-lg w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline",
          @class
        ]}
        {@rest}
      />
    """
  end
end
