defmodule TodoLvWeb.TodoLive.Index do
  @moduledoc """
  Manages the listing, creation, editing, sharing, and filtering of todos within a real-time LiveView.
  """
  alias TodoLv.Permissions
  alias TodoLv.Roles
  alias TodoLv.Categories
  use TodoLvWeb, :live_view

  alias TodoLv.Todos
  alias TodoLv.Todos.Todo

  # Assigns current user to socket
  on_mount {TodoLvWeb.UserAuth, :mount_current_user}

  @impl true
  @spec mount(any(), any(), map()) :: {:ok, map()}
  def mount(_params, _session, socket) do
    IO.inspect(socket)
    categories = Categories.list_categories_mapping()

    Appsignal.Logger.info(
      "index_mount",
      "Mounting the liveviw by #{socket.assigns.current_user.id}"
    )

    {:ok,
     socket
     |> assign(:searchForm, to_form(%{default_value: ""}))
     |> assign(:page_number, 1)
     |> assign(:toggle_bookmark, false)
     |> assign(:category, categories)}
  end

  @doc """
  Routes incoming requests to appropriate actions based on the live_action and params:

  :index: Renders the todo listing page.
  :new: Renders the form for creating a new todo.
  :edit: Renders the form for editing an existing todo.
  :share: Renders the form for sharing an existing todo with other users.
  """

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> handle_pagination(socket.assigns.page_number)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    Appsignal.Logger.info(
      "edit_apply_action",
      "Apply action the #{id} edit todo page by #{socket.assigns.current_user.id}"
    )

    todo = Todos.get_todo!(id)
    subtasks = todo.subtasks

    options = helper(subtasks)
    IO.inspect(options, label: "Options")

    cond do
      check_permission(socket.assigns.current_user.id, todo.id) == true ->
        Appsignal.Logger.info(
          "edit_apply_action",
          "Permission to access #{id} edit todo page granted to #{socket.assigns.current_user.id}"
        )

        socket
        |> assign(:page_title, "Edit Todo")
        |> assign(:todo, Todos.get_todo!(id))
        |> assign(:options, options)
        |> assign(:creator_id, todo.user_id)

      check_permission(socket.assigns.current_user.id, todo.id) == false ->
        Appsignal.Logger.warning(
          "edit_apply_action",
          "#{socket.assigns.current_user.id} tried to access #{id} edit todo page"
        )

        socket
        |> put_flash(:error, "View only: You cannot edit this todo.")
        |> redirect(to: "/todos")
    end
  end

  defp apply_action(socket, :share, %{"id" => id}) do
    IO.inspect("in share")
    IO.inspect(id)
    IO.inspect(socket.assigns.current_user.id)

    # Inside the form Creator role shouldnt be available
    roles =
      Roles.list_roles()
      |> Enum.filter(fn role -> role.role_name != "Creator" end)
      |> Enum.map(fn role -> role.role_name end)

    cond do
      check_permission(socket.assigns.current_user.id, id) == true ->
        Appsignal.Logger.info(
          "edit_apply_action",
          "Permission to access #{id} share todo page granted to #{socket.assigns.current_user.id}"
        )

        socket
        |> assign(:page_title, "Share Todo")
        |> assign(:todo, Todos.get_todo!(id))
        |> assign(:roles, roles)

      check_permission(socket.assigns.current_user.id, id) == false ->
        Appsignal.Logger.warning(
          "share_apply_action",
          "#{socket.assigns.current_user.id} tried to access #{id} share todo page"
        )

        socket
        |> put_flash(
          :error,
          "Access denied: You cannot adjust the sharing settings for this todo."
        )
        |> redirect(to: "/todos")
    end
  end

  defp apply_action(socket, :new, _params) do
    Appsignal.Logger.info(
      "new_apply_action",
      "Apply action to new todo page by #{socket.assigns.current_user.id}"
    )

    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
    |> assign(:creator_id, socket.assigns.current_user.id)
    |> assign(:options, helper([]))
  end

  defp apply_action(socket, :index, _params) do
    Appsignal.Logger.info(
      "new_apply_action",
      "Apply action for index page by #{socket.assigns.current_user.id}"
    )

    socket
    |> assign(:page_title, "Listing Todos")
  end

  @impl true
  def handle_info({TodoLvWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    Appsignal.Logger.info(
      "handle_info",
      "Handled the updation of #{todo.id} by #{socket.assigns.current_user.id}"
    )

    {:noreply,
     socket
     |> stream_insert(:todos, todo)}
  end

  # def handle_info({TodoLvWeb.TodoLive.FormComponent, {:msg, msg}}, socket) do
  #   IO.inspect(msg)
  #   {:noreply, socket}
  # end

  # ----------------- Buttons --------------
  @doc """
  Handles various user interactions within the LiveView:

  delete_todo: Deletes a todo with the given id.
  like_todo: Toggles the like status of a todo.
  bookmark_todos: Toggles the display of bookmarked todos.
  next_page and prev_page: Handle pagination navigation.
  search_todo: Searches for todos based on the provided query string.
  filter_todos: Filters todos based on status and category options.
  """
  @impl true
  def handle_event("delete_todo", %{"id" => id}, socket) do
    Appsignal.Logger.info(
      "handle_event",
      "Handled the deletion of todo #{id} by #{socket.assigns.current_user.id}"
    )

    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)

    {:noreply, stream_delete(socket, :todos, todo)}
  end

  @impl true
  def handle_event("like_todo", %{"id" => id}, socket) do
    Appsignal.Logger.info(
      "handle_event",
      "Handled the toggle like of todo #{id} by #{socket.assigns.current_user.id}"
    )

    todo = Todos.get_todo!(id)
    {:ok, updated_todo} = Todos.update_todo(todo, %{like: !todo.like})
    {:noreply, stream_insert(socket, :todos, updated_todo)}
  end

  @impl true
  def handle_event("bookmark_todos", _unsigned_paramz, socket) do
    if(socket.assigns.toggle_bookmark == false) do
      Appsignal.Logger.info(
        "handle_event",
        "Status of toggle = #{socket.assigns.toggle_bookmark} by #{socket.assigns.current_user.id}"
      )

      bookmarked_todos =
        Enum.filter(socket.assigns.current_user.todos, fn todo ->
          todo.like == true
        end)

      {:noreply,
       socket
       |> assign(:toggle_bookmark, !socket.assigns.toggle_bookmark)
       |> stream(:todos, bookmarked_todos, reset: true)}
    else
      Appsignal.Logger.info(
        "handle_event",
        "Status of toggle = #{socket.assigns.toggle_bookmark} by #{socket.assigns.current_user.id}"
      )

      {:noreply,
       socket
       |> assign(:toggle_bookmark, !socket.assigns.toggle_bookmark)
       |> handle_pagination(socket.assigns.page_number)}
    end
  end

  # --------- Pagination -------------------

  @impl true
  def handle_event("next_page", _unsigned_params, socket) do
    current_page_number = socket.assigns.page_number + 1
    IO.inspect(socket.assigns.page_number)

    Appsignal.Logger.info(
      "handle_event",
      "Pressed the next page #{current_page_number} by #{socket.assigns.current_user.id}"
    )

    {:noreply,
     socket
     |> assign(:page_number, current_page_number)
     |> handle_pagination(current_page_number)}
  end

  @impl true
  def handle_event("prev_page", _unsigned_params, socket) do
    current_page_number = socket.assigns.page_number - 1
    IO.inspect(socket.assigns.page_number)

    Appsignal.Logger.info(
      "handle_event",
      "Pressed the next page #{current_page_number} by #{socket.assigns.current_user.id}"
    )

    {:noreply,
     socket
     |> assign(:page_number, current_page_number)
     |> handle_pagination(current_page_number)}
  end

  # ---------------- Search ---------------------------

  @impl true
  def handle_event("search_todo", %{"default_value" => ""}, socket) do
    Appsignal.Logger.info(
      "handle_event",
      "Search bar was made empty by #{socket.assigns.current_user.id}"
    )

    {:noreply, handle_pagination(socket, socket.assigns.page_number)}
  end

  # %{"_target" => ["default_value"], "default_value" => search_query}
  @impl true
  def handle_event("search_todo", %{"default_value" => search_query}, socket) do
    Appsignal.Logger.info(
      "handle_event",
      "Searching #{search_query} by #{socket.assigns.current_user.id}"
    )

    todos = Todos.search_todo(search_query)

    filtered_todos =
      Enum.filter(todos, fn todo ->
        todo.user_id == socket.assigns.current_user.id
      end)

    {:noreply, stream(socket, :todos, filtered_todos, reset: true)}
  end

  # ------------- Filtering --------------------------------
  @impl true
  def handle_event("filter_todos", %{"status" => status, "category" => category}, socket) do
    # %{"_target" => ["status"], "status" => status}

    Appsignal.Logger.info(
      "handle_event",
      "Filtering todos by #{status} and #{category} by #{socket.assigns.current_user.id}"
    )

    if(status == "all") do
      filteredTodos =
        Enum.filter(socket.assigns.current_user.todos, fn todo ->
          todo.category.name == category
        end)

      {:noreply, stream(socket, :todos, filteredTodos, reset: true)}
    else
      filteredTodos =
        Enum.filter(socket.assigns.current_user.todos, fn todo ->
          todo.status == status && todo.category.name == category
        end)

      {:noreply, stream(socket, :todos, filteredTodos, reset: true)}
    end
  end

  @impl true
  def handle_event("filter_todos", %{"category" => category}, socket) do
    # {:noreply, socket}
    Appsignal.Logger.info(
      "handle_event",
      "Filtering todos by #{category} by #{socket.assigns.current_user.id}"
    )

    filteredTodos =
      Enum.filter(socket.assigns.current_user.todos, fn todo ->
        todo.category.name == category
      end)

    {:noreply, stream(socket, :todos, filteredTodos, reset: true)}
  end

  @impl true
  def handle_event("filter_todos", %{"status" => status}, socket) do
    # %{"_target" => ["status"], "status" => status}
    # IO.inspect(params)
    Appsignal.Logger.info(
      "handle_event",
      "Filtering todos by #{status} by #{socket.assigns.current_user.id}"
    )

    IO.inspect(status, label: "status")

    if(status == "all") do
      {:noreply, handle_pagination(socket, socket.assigns.page_number)}
    else
      filteredTodos =
        Enum.filter(socket.assigns.current_user.todos, fn todo ->
          todo.status == status
        end)

      {:noreply, stream(socket, :todos, filteredTodos, reset: true)}
    end
  end

  # ------------- Private Helper functions ---------------
  # Useful for routes which only need to check if edit access is present
  # Returns true -> Edit access
  # false -> Only View access // no permission
  defp check_permission(user_id, todo_id) do
    permission = Permissions.get_user_todo_permission(user_id, todo_id)
    IO.inspect(permission, label: "current permission")

    cond do
      permission == nil ->
        false

      permission.role_id == Roles.get_role_by_name!("Creator").id ||
          permission.role_id == Roles.get_role_by_name!("Editor").id ->
        true

      true ->
        false
    end
  end

  defp handle_pagination(socket, current_page_number) do
    paginated_todos =
      socket.assigns.current_user.todos
      |> Enum.sort_by(& &1.updated_at, Date)
      |> Enum.reverse()
      |> Enum.slice((current_page_number - 1) * 4, 4)

    max_page_no = div(length(socket.assigns.current_user.todos), 4)

    # the no of todos are such that they fit inside the page
    if(rem(length(socket.assigns.current_user.todos), 4) == 0) do
      socket
      |> assign(:max_page_number, max_page_no)
      |> stream(:todos, paginated_todos)
    else
      # the no of todos are such that they dont fit inside the page, therefore an additional page is required
      socket
      |> assign(:max_page_number, max_page_no + 1)
      |> stream(:todos, paginated_todos, reset: true)
    end
  end

  defp helper(subtasks) do
    # Extracts only status from a subtask
    # ["Complete", "In-Progress", "Hold", "Complete"]
    status_list =
      Enum.map(subtasks, fn subtask ->
        subtask.status
      end)

    # Returns a list of options for todo based upon status of subtask
    cond do
      # If no subtask -> Todo can have any status
      length(subtasks) == 0 -> ["Hold", "In-Progress", "Complete"]
      # If any In-progress -> In progress
      "In-Progress" in status_list -> ["In-Progress"]
      # If all hold -> hold
      Enum.all?(status_list, fn status -> status == "Hold" end) -> ["Hold"]
      Enum.all?(status_list, fn status -> status == "Complete" end) -> ["Complete"]
      true -> ["Hold"]
    end
  end
end
