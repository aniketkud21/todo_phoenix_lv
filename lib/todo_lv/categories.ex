defmodule TodoLv.Categories do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Repo

  alias TodoLv.Categories.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category) |> Repo.preload(:todos)
  end

  @doc """
  Returns the list of categories with mapping to id.

  ## Examples

      iex> list_categories_mapping()
      [{"Study", 1}, {"Household", 2}, {"Work", 3}]
  """
  def list_categories_mapping() do
    Repo.all(Category)
    |> Enum.map(&{&1.name, &1.id})
  end
#   @doc """
#   Gets a single todo.

#   Raises `Ecto.NoResultsError` if the Todo does not exist.

#   ## Examples

#       iex> get_todo!(123)
#       %Todo{}

#       iex> get_todo!(456)
#       ** (Ecto.NoResultsError)

#   """
#   def get_todo!(id), do: Repo.get!(Todo, id) |> Repo.preload(:user)

#   @doc """
#   Creates a todo.

#   ## Examples

#       iex> create_todo(%{field: value})
#       {:ok, %Todo{}}

#       iex> create_todo(%{field: bad_value})
#       {:error, %Ecto.Changeset{}}

#   """
#   def create_todo(attrs \\ %{}) do
#     %Todo{}
#     |> Todo.changeset(attrs)
#     |> Repo.insert()
#   end

#   @doc """
#   Updates a todo.

#   ## Examples

#       iex> update_todo(todo, %{field: new_value})
#       {:ok, %Todo{}}

#       iex> update_todo(todo, %{field: bad_value})
#       {:error, %Ecto.Changeset{}}

#   """
#   def update_todo(%Todo{} = todo, attrs) do
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
#     Todo.changeset(todo, attrs)
#   end
end
