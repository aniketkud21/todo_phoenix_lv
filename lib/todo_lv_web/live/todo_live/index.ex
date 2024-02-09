defmodule TodoLvWeb.TodoLive.Index do
  alias TodoLv.Categories
  alias TodoLv.Accounts
  use TodoLvWeb, :live_view

  alias TodoLv.Todos
  alias TodoLv.Todos.Todo

  @impl true
  def mount(_params, session, socket) do
    IO.inspect(socket, label: "on mount")
    user = Accounts.get_user_by_session_token(session["user_token"])

    categories = Categories.list_categories_temp()

    {:ok,
   socket
   |> assign(searchForm: to_form(%{default_value: ""}))
   |> assign(:user, user)
   |> assign(:page_number, 1)
   |> assign(:toggle_bookmark, false)
   |> assign(:category, categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    todo = Todos.get_todo!(id)
    subtasks = todo.subtasks
    # IO.inspect("IN edit")
    options = helper(subtasks)
    IO.inspect(options, label: "Options")

    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, Todos.get_todo!(id))
    |> assign(:options, options)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
  end

  defp apply_action(socket, :index, _params) do
    paginated_todos = handle_pagination(socket, socket.assigns.page_number)

    max_page_no = div(length(socket.assigns.user.todos),4)

    if(rem(length(socket.assigns.user.todos),4) == 0) do

      socket
      |> assign(:page_title, "Listing Todos")
      |> assign(:max_page_number, max_page_no)
      |> stream(:todos, paginated_todos)
    else

      socket
      |> assign(:page_title, "Listing Todos")
      |> assign(:max_page_number, max_page_no + 1)
      |> stream(:todos, paginated_todos)
    end
  end

  @impl true
  def handle_info({TodoLvWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    {:noreply,
    socket
    |> stream_insert(:todos, todo)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)

    {:noreply, stream_delete(socket, :todos, todo)}
  end

  @impl true
  def handle_event("next", _unsigned_params, socket) do
    current_page_number = socket.assigns.page_number + 1
    IO.inspect(socket.assigns.page_number)

    paginated_todos = handle_pagination(socket, current_page_number)
    {:noreply, socket
    |> assign(:page_number, current_page_number)
    |> stream(:todos, paginated_todos, reset: true)}
  end

  @impl true
  def handle_event("prev", _unsigned_params, socket) do
    current_page_number = socket.assigns.page_number - 1
    IO.inspect(socket.assigns.page_number)

    paginated_todos = handle_pagination(socket, current_page_number)
    {:noreply, socket
    |> assign(:page_number, current_page_number)
    |> stream(:todos, paginated_todos, reset: true)}
  end

  @impl true
  def handle_event("heartpress", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, updated_todo} = Todos.update_todo(todo , %{like: !todo.like})
    {:noreply, stream_insert(socket, :todos, updated_todo)}
  end

  @impl true
  def handle_event("bookmarkpress", _unsigned_paramz, socket) do
    if(socket.assigns.toggle_bookmark == false) do
      bookmarked_todos = Enum.filter(socket.assigns.user.todos, fn todo ->
        todo.like == true
      end)

      IO.inspect(bookmarked_todos, label: "btodos")

      {:noreply,
      socket
      |> assign(:toggle_bookmark, !socket.assigns.toggle_bookmark)
      |> stream(:todos, bookmarked_todos, reset: true)}
    else
      paginated_todos = handle_pagination(socket, socket.assigns.page_number)

      {:noreply,
      socket
      |> assign(:toggle_bookmark, !socket.assigns.toggle_bookmark)
      |> stream(:todos, paginated_todos, reset: true)}
    end
  end

  @impl true
  def handle_event("searchTodo", %{"_target" => ["default_value"], "default_value" => ""}, socket) do
    paginated_todos = handle_pagination(socket, socket.assigns.page_number)
    {:noreply, stream(socket, :todos, paginated_todos, reset: true)}
  end

  @impl true
  def handle_event("searchTodo", %{"_target" => ["default_value"], "default_value" => search_query}, socket) do
    todos = Todos.search(search_query)
    IO.inspect(todos, label: "Search todos")
    filtered_todos = Enum.filter(todos, fn todo ->
      todo.user_id == socket.assigns.user.id
    end)
    {:noreply, stream(socket, :todos, filtered_todos, reset: true)}
  end

  @impl true
  def handle_event("filterTodos", %{"_target" => ["status"], "status" => status}, socket) do
    IO.inspect(status)

    if(status == "all") do
      paginated_todos = handle_pagination(socket, socket.assigns.page_number)

      {:noreply,
      socket
      |> stream(:todos, paginated_todos, reset: true)}
    else
      filteredTodos = Enum.filter(socket.assigns.user.todos, fn todo ->
        todo.status == status
      end)
      {:noreply, stream(socket, :todos, filteredTodos, reset: true)}
    end
  end

  defp handle_pagination(socket, current_page_number) do
    socket.assigns.user.todos
    |> Enum.sort_by(&(&1.updated_at), Date)
    |> Enum.reverse()
    |> Enum.slice((current_page_number-1) * 4 , 4)
  end

  defp helper(subtasks) do
    status_list = Enum.map(subtasks, fn subtask ->
      subtask.status
    end)

    IO.inspect(status_list, label: "oNLY STATUS")
    cond do
      length(subtasks) == 0 -> ["Hold", "In-Progress", "Complete"]
      "In-Progress" in status_list -> ["In-Progress"]
      Enum.all?(status_list, fn status -> status=="Hold" end) -> ["Hold"]
      Enum.all?(status_list, fn status -> status=="Complete" end) -> ["Complete"]
      true -> ["Hold"]
    end
  end
end
