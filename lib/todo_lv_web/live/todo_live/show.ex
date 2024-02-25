defmodule TodoLvWeb.TodoLive.Show do
  alias TodoLv.Subtasks
  alias TodoLv.Permissions
  alias TodoLv.Roles
  alias TodoLv.Subtasks.Subtask
  use TodoLvWeb, :live_view

  alias TodoLv.Todos

  on_mount {TodoLvWeb.UserAuth, :check_permission_level}

  @impl true
  def mount(params, _session, socket) do
    IO.inspect(params["id"])

    Phoenix.PubSub.subscribe(TodoLv.PubSub, "subtask:#{params["id"]}")
    Phoenix.PubSub.subscribe(TodoLv.PubSub, "share:#{params["id"]}")
    # user = Accounts.get_user_by_session_token(session["user_token"])
    # %{view: view, edit: edit} = check_permission(socket.assigns.current_user.id, params["id"])
    {:ok, socket}
    # |> assign(:view, view)
    # |> assign(:edit, edit)}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # defp check_permission(user_id, todo_id) do
  #   permission = Permissions.get_permission_by_user_id!(user_id, todo_id)
  #   cond do
  #     permission.role_id==2 -> %{view: true, edit: false}
  #     permission.role_id==3 || permission.role_id==1 -> %{view: true, edit: true}
  #     true -> %{view: false, edit: false}
  #   end
  # end

  defp apply_action(socket, :show, params) do
    IO.inspect(params)
    %{"id" => id} = params
    subtasks = Todos.get_todo!(id).subtasks

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:todo, Todos.get_todo!(id))
    |> stream(:subtasks, subtasks)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, %Subtask{})
  end

  defp apply_action(socket, :edit, params) do
    %{"subtask_id" => subtask_id} = params

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, Subtasks.get_subtask!(subtask_id))
  end

  # handles the updation of status of todo based on status of subtasks
  @impl true
  def handle_info(
        {TodoLvWeb.TodoLive.SubtaskFormComponent, {:saved, subtask, :todo_id, todo_id}},
        socket
      ) do
    todo = Todos.get_todo!(todo_id)
    subtasks = todo.subtasks
    list = helper(subtasks)

    Todos.update_todo(todo, %{status: Enum.at(list, 0)})

    {:noreply,
     socket
     |> stream_insert(:subtasks, subtask)}
  end

  # Handles Pubsub
  def handle_info({:subtask, subtask}, socket) do
    {:noreply,
     socket
     |> stream_insert(:subtasks, subtask)}
  end

  def handle_info({:delete_msg, msg}, socket) do
    IO.inspect("deleted permission")

    {:noreply,
     socket
     |> put_flash(:error, msg)
     |> redirect(to: ~p"/todos")}
  end

  def handle_info({:update_msg, msg, :edit_access, edit_access}, socket) do
    IO.inspect(msg)

    {:noreply,
     socket
     |> assign(:edit, edit_access)
     |> put_flash(:info, msg)}
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

  defp helper(subtasks) do
    status_list =
      Enum.map(subtasks, fn subtask ->
        subtask.status
      end)

    IO.inspect(status_list, label: "oNLY STATUS")

    cond do
      length(subtasks) == 0 -> ["Hold", "In-Progress", "Complete"]
      "In-Progress" in status_list -> ["In-Progress"]
      Enum.all?(status_list, fn status -> status == "Hold" end) -> ["Hold"]
      Enum.all?(status_list, fn status -> status == "Complete" end) -> ["Complete"]
      true -> ["Hold"]
    end
  end

  defp page_title(:new), do: "New SubTask"
  defp page_title(:show), do: "Show Todo"
  defp page_title(:edit), do: "Edit SubTask"
end
