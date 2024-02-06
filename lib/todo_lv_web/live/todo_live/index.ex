defmodule TodoLvWeb.TodoLive.Index do
  alias TodoLv.Categories
  alias TodoLv.Accounts
  use TodoLvWeb, :live_view

  alias TodoLv.Todos
  alias TodoLv.Todos.Todo

  @impl true
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    categories = Categories.list_categories_temp()
    {:ok,
   socket
   #|> stream(:todos, user.todos)
   |> assign(searchForm: to_form(%{default_value: ""}))
   |> assign(:user, user)
   |> assign(:page_number, 1)
   |> assign(:category, categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, Todos.get_todo!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
  end

  defp apply_action(socket, :index, _params) do
    paginated_todos = handle_pagination(socket, socket.assigns.page_number)

    socket
    |> assign(:page_title, "Listing Todos")
    |> stream(:todos, paginated_todos)
  end

  @impl true
  def handle_info({TodoLvWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    # paginated_todos = handle_pagination(socket, socket.assigns.page_number)
    IO.inspect(todo, label: "In Hanfle info")
    todo = TodoLv.Repo.preload(todo, [:user, :category])
    IO.inspect(todo, label: "In Hanfle info2")
    {:noreply,
    socket
    |> stream_insert(:todos, todo)}
    # |> stream(:todos, paginated_todos)}
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


  # -------------------------
  @impl true
  def handle_event("heartpress", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    IO.inspect(todo, label: "fIRST")
    #updatedMap = Map.update!(todo, :like, fn x-> !x end) |> IO.inspect()
    #Todos.change_todo(updatedMap)

    updated_todo = Todos.update_todo(todo , %{like: !todo.like})
    IO.inspect(updated_todo, label: "Updated todo")
    # IO.inspect(Todos.get_todo!(id), label: "HELLOSSSSSS")


    # Used stream instead of assign
    {:noreply, stream_insert(socket, :todos, Todos.get_todo!(id))}
    # Todos.update_todo(todo, {like: !(todo.like)})
  end

  # # --------------------------  %{"_target" => ["default_value"], "default_value" => "s"}
  @impl true
  def handle_event("searchTodo", %{"_target" => ["default_value"], "default_value" => ""}, socket) do
    # IO.inspect(search_query)
    IO.inspect("Empty search")
    #todos = Todos.search(search_query)
    paginated_todos = handle_pagination(socket, socket.assigns.page_number)
    {:noreply, stream(socket, :todos, paginated_todos, reset: true)}
  end

  @impl true
  def handle_event("searchTodo", %{"_target" => ["default_value"], "default_value" => search_query}, socket) do
    IO.inspect(search_query)
    # IO.inspect(socket)
    todos = Todos.search(search_query)
    filtered_todos = Enum.filter(todos, fn todo ->
      todo.user_id == socket.assigns.user.id
    end)
    # IO.inspect(todos, label: "Search Todos")
    {:noreply, stream(socket, :todos, filtered_todos, reset: true)}
  end

  defp handle_pagination(socket, current_page_number) do
    IO.inspect(socket.assigns.user.todos, label: "ALL TODOS")
    socket.assigns.user.todos
    |> Enum.sort_by(&(&1.updated_at), Date)
    |> Enum.reverse()
    |> Enum.slice((current_page_number-1) * 4 , 4)
  end
end
