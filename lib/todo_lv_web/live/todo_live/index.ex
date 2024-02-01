defmodule TodoLvWeb.TodoLive.Index do
  alias TodoLv.Accounts
  use TodoLvWeb, :live_view

  alias TodoLv.Todos
  alias TodoLv.Todos.Todo

  @impl true
  def mount(_params, session, socket) do
    # {:ok, stream(socket, :todos, Todos.list_todos())}
    user = Accounts.get_user_by_session_token(session["user_token"])
    IO.inspect(user)
    #user_id = user.id
    # IO.inspect(Todos.list_todos)
    {:ok,
   socket
   #|> stream(:todos, user.todos)
   |> assign(searchForm: to_form(%{default_value: ""}))
   |> assign(:user, user)
   |> assign(:page_number, 1)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    IO.inspect(id)
    #IO.inspect(socket, label: "Edit")
    IO.inspect(Todos.get_todo!(id), label: "User in Edit")
    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, Todos.get_todo!(id))
  end

  defp apply_action(socket, :new, _params) do
    # IO.inspect(socket, label: "Socket Data")
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
  end

  defp apply_action(socket, :index, _params) do
    sorted_todos = socket.assigns.user.todos
    |> Enum.sort_by(&(&1.updated_at), Date)
    |> Enum.reverse()
    |> Enum.slice(socket.assigns.page_number*2 , 2)

    socket
    |> assign(:page_title, "Listing Todos")
    |> stream(:todos, sorted_todos)
  end

  @impl true
  def handle_info({TodoLvWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    {:noreply, stream_insert(socket, :todos, todo)}
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

    IO.inspect(socket)
    # Used stream instead of assign
    {:noreply, stream_insert(socket, :todos, Todos.get_todo!(id))}
    # Todos.update_todo(todo, {like: !(todo.like)})
  end

  # # --------------------------  %{"_target" => ["default_value"], "default_value" => "s"}
  # @impl true
  # def handle_event("searchTodo", %{"_target" => ["default_value"], "" => search_query}, socket) do
  #   IO.inspect(search_query)
  #   #todos = Todos.search(search_query)
  #   {:noreply, stream(socket, :todos, [], reset: true)}
  # end

  @impl true
  def handle_event("searchTodo", %{"_target" => ["default_value"], "default_value" => search_query}, socket) do
    IO.inspect(search_query)
    # IO.inspect(socket)
    todos = Todos.search(search_query)
    filtered_todos = Enum.filter(todos, fn todo ->
      todo.user_id == socket.assigns.user.id
    end)
    IO.inspect(todos, label: "Search Todos")
    {:noreply, stream(socket, :todos, filtered_todos, reset: true)}
  end

  defp handle_pagination(socket, current_page_number) do
    socket.assigns.user.todos
    |> Enum.sort_by(&(&1.updated_at), Date)
    |> Enum.reverse()
    |> Enum.slice((current_page_number-1) * 2 , 2)
  end

  # def handle_event("searchTodo", %{"default_value" => searchEntry}, socket) do
  #   IO.inspect(searchEntry)
  #   all_todos = Todos.list_todos()
  #   filtered_todos = Enum.filter(all_todos, fn x ->
  #     x[:title] !=searchEntry
  #   end)
  #   IO.inspect(filtered_todos)
  #   {:noreply, stream(socket, :todos, filtered_todos)}
  # end
end
