defmodule TodoLvWeb.TodoJSON do
  alias TodoLv.Subtasks.Subtask
  alias TodoLv.Todos.Todo

  @doc """
  Renders a list of todos.
  """
  def index(%{todos: todos}) do
    %{data: for(todo <- todos, do: data(todo))}
  end

  def error() do
    %{error: "Incorrect credentials"}
  end

  defp data(%Todo{} = todo) do
    %{
      id: todo.id,
      title: todo.title,
      desc: todo.desc,
      status: todo.status,
      category: todo.category.name,
      subtasks: for(subtask <- todo.subtasks, do: subtask_data(subtask))
    }
  end

  defp subtask_data(%Subtask{} = subtask) do
    %{
      id: subtask.id,
      title: subtask.title,
      desc: subtask.desc,
      status: subtask.status
    }
  end
end
