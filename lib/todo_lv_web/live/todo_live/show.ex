defmodule TodoLvWeb.TodoLive.Show do
  @moduledoc """
  This LiveView module handles displaying, creating, and editing subtasks
  associated with a specific todo. It leverages Phoenix.PubSub for real-time
  updates and implements permission checks based on user roles.
  """
  alias TodoLv.Subtasks
  alias TodoLv.Subtasks.Subtask
  use TodoLvWeb, :live_view

  alias TodoLv.Todos

  on_mount {TodoLvWeb.UserAuth, :check_permission_level}

  @impl true
  def mount(params, _session, socket) do
    IO.inspect(params["id"])

    Appsignal.Logger.info(
      "show_mount",
      "Mounting the #{params["id"]} page by #{socket.assigns.current_user.id}"
    )

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
    Appsignal.Logger.info(
      "show_apply_action",
      "Apply action the #{params["id"]} page by #{socket.assigns.current_user.id}"
    )

    IO.inspect(params)
    %{"id" => id} = params
    subtasks = Todos.get_todo!(id).subtasks

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:todo, Todos.get_todo!(id))
    |> stream(:subtasks, subtasks)
  end

  defp apply_action(socket, :new, params) do
    Appsignal.Logger.info(
      "new_apply_action",
      "Apply action the new subtask page by #{socket.assigns.current_user.id} for todo #{params["id"]}"
    )

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, %Subtask{})
  end

  defp apply_action(socket, :edit, params) do
    Appsignal.Logger.info(
      "edit_apply_action",
      "Apply action the #{params["id"]} edit page by #{socket.assigns.current_user.id}"
    )

    %{"subtask_id" => subtask_id} = params

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, Subtasks.get_subtask!(subtask_id))
  end

  @doc """
  Responsibilities:

  **Handles messages from:
  SubtaskFormComponent: Updates todo status based on subtasks.
  PubSub: Streams subtask updates and handles permission changes.
  Function Docs:

  handle_info({TodoLvWeb.TodoLive.SubtaskFormComponent, {:saved, subtask, :todo_id, todo_id}}, socket):
  Updates todo status based on subtask completion using helper/1.
  Updates the todo in the database.
  Streams the saved subtask to clients.

  handle_info({:subtask, subtask}, socket):
  Inserts a new or updated subtask into the live view stream.

  handle_info({:delete_msg, msg}, socket):
  Displays an error message about revoked permissions.
  Redirects to the todos list.

  handle_info({:update_msg, msg, :edit_access, edit_access}, socket):
  Updates the edit permission for the user.
  Displays an informational message about the permission change.
  """

  # handles the updation of status of todo based on status of subtasks
  @impl true
  def handle_info(
        {TodoLvWeb.TodoLive.SubtaskFormComponent, {:saved, subtask, :todo_id, todo_id}},
        socket
      ) do
    Appsignal.Logger.info(
      "handle_info",
      "Handled the updation of status of #{todo_id} based on #{subtask.id} by #{socket.assigns.current_user.id}"
    )

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
    Appsignal.Logger.info(
      "handle_info",
      "Handled the addition of new subtask #{subtask.id} by #{socket.assigns.current_user.id}"
    )

    {:noreply,
     socket
     |> stream_insert(:subtasks, subtask)}
  end

  def handle_info({:delete_msg, msg, :todo_id, todo_id}, socket) do
    IO.inspect("deleted permission")

    Appsignal.Logger.info(
      "handle_info",
      "Handled the deletion of permission of #{socket.assigns.current_user.id} on #{todo_id}"
    )

    {:noreply,
     socket
     |> put_flash(:error, msg)
     |> redirect(to: ~p"/todos")}
  end

  def handle_info({:update_msg, msg, :edit_access, edit_access, :todo_id, todo_id}, socket) do
    IO.inspect(msg)

    Appsignal.Logger.info(
      "handle_info",
      "Handled the updation of permission of #{socket.assigns.current_user.id} on #{todo_id}"
    )

    {:noreply,
     socket
     |> assign(:edit, edit_access)
     |> put_flash(:info, msg)}
  end

  @doc """
  Deletes a subtask with the given `id`.
  """
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Appsignal.Logger.info(
      "handle_event",
      "Handled the deletion of subtask of #{id} by #{socket.assigns.current_user.id}"
    )

    IO.inspect(id)
    subtask = Subtasks.get_subtask!(id)
    {:ok, _} = Subtasks.delete_subtask(subtask)

    {:noreply, stream_delete(socket, :subtasks, subtask)}
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
