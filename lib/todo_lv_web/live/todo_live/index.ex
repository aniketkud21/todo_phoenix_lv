defmodule TodoLvWeb.TodoLive.Index do
  use TodoLvWeb, :live_view

  alias TodoLv.Todos
  alias TodoLv.Todos.Todo

  @impl true
  def mount(_params, session, socket) do
    # {:ok, stream(socket, :todos, Todos.list_todos())}
    IO.inspect(session, label: "Session data")

    {:ok,
   socket
   # |> stream(:todos, Todos.list_todos)
   |> assign(searchForm: to_form(%{default_value: ""}))}

  end

  @impl true
  def handle_params(params, _url, socket) do
    # case Todos.list_todos(params) do
    #   {:ok, {todos, meta}} ->
    #     IO.inspect(meta)
    #     {:noreply,
    #        socket
    #        |> assign(:meta, meta)
    #        |> stream(:pets, todos, reset: true)
    #        |> apply_action(socket.assigns.live_action, params)}
    # end
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

  defp apply_action(socket, :index, params) do
    %{todos: todos, meta: meta} = Todos.list_todos(params)
    socket
    |> assign(:page_title, "Listing Todos")
    #|> assign(:todo, nil)
    |> stream(:todos, todos, reset: true)
    |> assign(:meta, meta)
  end

  @impl true
  def handle_info({TodoLvWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    {:noreply, stream_insert(socket, :todos, todo)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)
    IO.inspect(todo)
    {:noreply, stream_delete(socket, :todos, todo)}
  end

  # -------------------------
  @impl true
  def handle_event("heartpress", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    IO.inspect(todo, label: "fIRST")
    #updatedMap = Map.update!(todo, :like, fn x-> !x end) |> IO.inspect()
    #Todos.change_todo(updatedMap)

    Todos.update_todo(todo , %{like: !todo.like})
    IO.inspect(Todos.get_todo!(id), label: "HELLOSSSSSS")
    # IO.inspect(socket)
    # Used stream instead of assign
    {:noreply, stream_insert(socket, :todos, Todos.get_todo!(id))}
    # {:noreply, socket}
    # Todos.update_todo(todo, {like: !(todo.like)})
  end

  # --------------------------  %{"_target" => ["default_value"], "default_value" => "s"}
  # @impl true
  # def handle_event("searchTodo", %{"_target" => ["default_value"], "" => search_query}, socket) do
  #   IO.inspect(search_query)
  #   #todos = Todos.search(search_query)
  #   {:noreply, stream(socket, :todos, [], reset: true)}
  # end

  @impl true
  def handle_event("searchTodo", %{"_target" => ["default_value"], "default_value" => search_query}, socket) do
    IO.inspect(search_query)
    todos = Todos.search(search_query)
    #IO.inspect(todos)
    {:noreply, stream(socket, :todos, todos, reset: true)}
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
