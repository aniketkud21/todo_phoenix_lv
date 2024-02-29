defmodule TodoLvWeb.TodoJSON do
  alias TodoLv.Todos.Todo
  @doc """
  Renders a list of todos.
  """
  def index(%{todos: todos}) do
    %{data: for(todo <- todos, do: data(todo))}
  end

  defp data(%Todo{} = todo) do
    %{
      id: todo.id,
      title: todo.title,
      desc: todo.desc,
      status: todo.status
    }
  end
end
