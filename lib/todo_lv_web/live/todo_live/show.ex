defmodule TodoLvWeb.TodoLive.Show do
  alias TodoLv.Subtasks
  alias TodoLv.Subtasks.Subtask
  use TodoLvWeb, :live_view

  alias TodoLv.Todos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    IO.inspect(params)
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, params) do
    %{"id" => id} = params
    subtasks = Todos.get_todo!(id).subtasks

    IO.inspect(socket, label: "Stream data before")

    socket = socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:todo, Todos.get_todo!(id))
    |> stream(:subtasks, subtasks)

    IO.inspect(socket, label: "Stream data after for delete")

    socket
  end

  defp apply_action(socket, :new, params) do
    IO.inspect(params, label: "from new apply action")
    IO.inspect(%Subtask{}, label: "Empty struct")
    socket = socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, %Subtask{})


    socket
  end

  defp apply_action(socket, :edit, params) do
    %{"subtask_id" => subtask_id} = params
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, Subtasks.get_subtask!(subtask_id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    IO.inspect(id)
    subtask = Subtasks.get_subtask!(id)
    {:ok, _} = Subtasks.delete_subtask(subtask)

    IO.inspect(socket.assigns.streams, label: "before")
    x = stream_delete(socket, :subtasks, subtask)
    IO.inspect(socket.assigns.streams, label: "after")
    {:noreply, x}
  end

  defp page_title(:new), do: "New SubTask"
  defp page_title(:show), do: "Show Todo"
  defp page_title(:edit), do: "Edit SubTask"
end
