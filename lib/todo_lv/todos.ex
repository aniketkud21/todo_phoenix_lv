defmodule TodoLv.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Repo

  alias TodoLv.Todos.Todo

  @doc """
  Retrieves a list of all todos from the database, preloaded with their associated users and categories.

  ## Return value

  A list of %Todo{} structs, each preloaded with:

  - The associated %User{} struct who created the todo.
  - The associated %Category{} struct to which the todo belongs.

  ## Note

  - The order of the returned todos is not guaranteed.

  ## Examples

  iex> TodoLv.Todos.list_todos()
  # Returns a list of %Todo{} structs, preloaded with users and categories

  """
  def list_todos do
    Repo.all(Todo) |> Repo.preload(:user) |> Repo.preload(:category)
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Return value

  - A %Todo{} struct with the specified ID:
      - Includes attributes like `action`, `resource`, etc.
      - Preloaded with:
          - The associated %User{} struct who created the todo.
          - The associated %Category{} struct to which the todo belongs.
          - The associated list of %Subtask{} structs of the todo.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id) |> Repo.preload(:user) |> Repo.preload(:category) |> Repo.preload(:subtasks)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}) do
    IO.inspect(attrs, label: "Attributes in create")
    %Todo{}
    |> Todo.changeset(attrs)
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
  def update_todo(%Todo{} = todo, attrs) do
    IO.inspect(todo, label: "todo In updatetodo")
    IO.inspect(attrs, label: "attrs in updatetodo")
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    Repo.delete_all(from(p in TodoLv.Permissions.Permission, where: p.todo_id == ^todo.id))
    Repo.delete(todo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    IO.inspect(attrs, label: "Attributes")
    Todo.changeset(todo, attrs)
  end

  @doc """
  Searches for todos matching a given search query.

  The search is case-insensitive and matches the query against the todo title.

  ## Examples

      iex> search_todo("buy")
      # Returns a list of todos containing "buy" in their title, ordered by title (ascending)

      iex> search_todo("meeting")
      # Returns a list of todos containing "meeting" in their title, ordered by title (ascending)

  """
  def search_todo(search_query) do
    search_query = "%#{search_query}%"
    IO.inspect(search_query)
    Todo
    |> order_by(asc: :title)
    |> where([t], ilike(t.title, ^search_query))
    #|> limit(5)
    |> Repo.all()
    |> Repo.preload(:user)
    |> Repo.preload(:category)
    |> Repo.preload(:subtasks)
  end
end
