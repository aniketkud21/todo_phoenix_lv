defmodule TodoLv.Subtasks do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Repo

  alias TodoLv.Subtasks.Subtask

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_subtasks do
    Repo.all(Subtask)
  end

  # def list_subtasks_by_todo do
  #   Repo.a
  # end

#   @doc """
#   Gets a single todo.

#   Raises `Ecto.NoResultsError` if the Todo does not exist.

#   ## Examples

#       iex> get_todo!(123)
#       %Todo{}

#       iex> get_todo!(456)
#       ** (Ecto.NoResultsError)

#   """
#   def get_todo!(id), do: Repo.get!(Todo, id) |> Repo.preload(:user) |> Repo.preload(:category)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subtask(attrs \\ %{}) do
    IO.inspect(attrs, label: "Attributes in create")
    something = %Subtask{}
    |> Subtask.changeset(attrs)
    |> Repo.insert()

    IO.inspect(something, label: "Why fails")
    something
  end

#   @doc """
#   Updates a todo.

#   ## Examples

#       iex> update_todo(todo, %{field: new_value})
#       {:ok, %Todo{}}

#       iex> update_todo(todo, %{field: bad_value})
#       {:error, %Ecto.Changeset{}}

#   """
#   def update_todo(%Todo{} = todo, attrs) do
#     IO.inspect(todo, label: "todo In updatetodo")
#     IO.inspect(attrs, label: "attrs in updatetodo")
#     todo
#     |> Todo.changeset(attrs)
#     |> Repo.update()
#   end

#   @doc """
#   Deletes a todo.

#   ## Examples

#       iex> delete_todo(todo)
#       {:ok, %Todo{}}

#       iex> delete_todo(todo)
#       {:error, %Ecto.Changeset{}}

#   """
#   def delete_todo(%Todo{} = todo) do
#     Repo.delete(todo)
#   end

#   @doc """
#   Returns an `%Ecto.Changeset{}` for tracking todo changes.

#   ## Examples

#       iex> change_todo(todo)
#       %Ecto.Changeset{data: %Todo{}}

#   """
#   def change_todo(%Todo{} = todo, attrs \\ %{}) do
#     IO.inspect(attrs, label: "Attributes")
#     Todo.changeset(todo, attrs)
#   end
    def change_subtask(%Subtask{} = subtask, attrs \\ %{}) do
      IO.inspect(attrs, label: "Attributes")
      Subtask.changeset(subtask, attrs)
    end

# # --------------------------------------
#   def search(search_query) do
#     search_query = "%#{search_query}%"
#     IO.inspect(search_query)
#     Todo
#     |> order_by(asc: :title)
#     |> where([t], ilike(t.title, ^search_query))
#     #|> limit(5)
#     |> Repo.all()
#     |> Repo.preload(:user)
#     |> Repo.preload(:category)
#   end
end


# where([t], ilike(t.status, ^search_query))
