defmodule TodoLv.Permissions do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Repo

  alias TodoLv.Permissions.Permission

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%Todo{}, ...]

  """
  # def list_todos do
  #   Repo.all(Todo) |> Repo.preload(:user) |> Repo.preload(:category)
  # end

  # @doc """
  # Gets a single todo.

  # Raises `Ecto.NoResultsError` if the Todo does not exist.

  # ## Examples

  #     iex> get_todo!(123)
  #     %Todo{}

  #     iex> get_todo!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_todo!(id), do: Repo.get!(Todo, id) |> Repo.preload(:user) |> Repo.preload(:category) |> Repo.preload(:subtasks)

  @doc """
  Creates a permission.

  ## Examples

      iex> create_permission(%{field: value})
      {:ok, %Permission{}}

      iex> create_permission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_permission(attrs \\ %{}) do
    IO.inspect(attrs, label: "Attributes in create")
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  # def update_todo(%Todo{} = todo, attrs) do
  #   IO.inspect(todo, label: "todo In updatetodo")
  #   IO.inspect(attrs, label: "attrs in updatetodo")
  #   todo
  #   |> Todo.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a todo.

  # ## Examples

  #     iex> delete_todo(todo)
  #     {:ok, %Todo{}}

  #     iex> delete_todo(todo)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_todo(%Todo{} = todo) do
  #   Repo.delete(todo)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking todo changes.

  # ## Examples

  #     iex> change_todo(todo)
  #     %Ecto.Changeset{data: %Todo{}}

  # """
  # def change_todo(%Todo{} = todo, attrs \\ %{}) do
  #   IO.inspect(attrs, label: "Attributes")
  #   Todo.changeset(todo, attrs)
  # end
end
