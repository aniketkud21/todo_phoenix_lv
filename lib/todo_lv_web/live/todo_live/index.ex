defmodule TodoLvWeb.TodoLive.Index do
  use TodoLvWeb, :live_view

  alias TodoLv.Todos
  alias TodoLv.Todos.Todo

  @impl true
  def mount(_params, _session, socket) do
    # {:ok, stream(socket, :todos, Todos.list_todos())}
    {:ok,
   socket
   |> stream(:todos, Todos.list_todos())}

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
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
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

  # -------------------------

  def handle_event("heartpress", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    IO.inspect(todo, label: "fIRST")
    #updatedMap = Map.update!(todo, :like, fn x-> !x end) |> IO.inspect()
    #Todos.change_todo(updatedMap)

    Todos.update_todo(todo , %{like: !todo.like})
    IO.inspect(Todos.get_todo!(id), label: "HELLOSSSSSS")
    # IO.inspect(socket)
    # Used stream instead of assign
    {:noreply, stream(socket, :todos, Todos.list_todos)}
    # Todos.update_todo(todo, {like: !(todo.like)})
  end
end
