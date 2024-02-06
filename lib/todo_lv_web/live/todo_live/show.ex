defmodule TodoLvWeb.TodoLive.Show do
  alias TodoLv.Subtasks
  alias TodoLv.Subtasks.Subtask
  use TodoLvWeb, :live_view

  alias TodoLv.Todos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # @impl true
  # def handle_params(%{"id" => id}, _, socket) do
  #   {:noreply,
  #    socket
  #    |> assign(:page_title, page_title(socket.assigns.live_action))
  #    |> assign(:todo, Todos.get_todo!(id))}
  # end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, id)}
  end

  defp apply_action(socket, :show, id) do
    subtasks = Todos.get_todo!(id).subtasks
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:todo, Todos.get_todo!(id))
    |> stream(:subtasks, subtasks)


  end

  defp apply_action(socket, :new, params) do
    IO.inspect(params, label: "from new apply action")
    IO.inspect(%Subtask{}, label: "Empty struct")
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, %Subtask{})
  end

  # @impl true
  # def handle_params(params, _, socket) do
  #   IO.inspect(socket.assigns.live_action)
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  # defp apply_action(socket, :new, _params) do
  #   socket
  #   |> assign(:page_title, "New Subtask")
  #   # |> assign(:todo, %Todo{})
  # end
  defp page_title(:new), do: "New SubTask"
  defp page_title(:show), do: "Show Todo"
  defp page_title(:edit), do: "Edit Todo"
  # defp page_title(:new), do: ""
end
