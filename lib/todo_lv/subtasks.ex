defmodule TodoLv.Subtasks do
  @moduledoc """
  The Subtasks context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Repo

  alias TodoLv.Subtasks.Subtask

  @doc """
  Returns the list of subtasks.

  ## Examples

      iex> list_subtasks()
      [%Subtask{}, ...]

  """
  def list_subtasks do
    Repo.all(Subtask)
  end

  @doc """
  Fetches a specific subtask by its ID, raising an error if it doesn't exist.

  **Arguments:**

  - `id` (integer): The unique identifier of the subtask to retrieve.

  **Return value:**

  - A %Subtask{} struct representing the subtask with the specified ID, preloaded with its associated todo.

  **Raises:**

  - `Ecto.NoResultsError`: If no subtask with the given ID is found.

  ## Examples:

  iex> TodoLv.Subtasks.get_subtask!(123)
  # Returns the %Subtask{} struct with ID 123, preloaded with its todo

  iex> TodoLv.Subtasks.get_subtask!(456)
  # Raises `Ecto.NoResultsError` if no subtask with ID 456 exists

  """
  def get_subtask!(id), do: Repo.get!(Subtask, id) |> Repo.preload(:todo)

  @doc """
  Creates a subtask.

  ## Examples

      iex> create_subtask(%{field: value})
      {:ok, %Subtask{}}

      iex> create_subtask(%{field: bad_value})
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

  @doc """
  Updates a subtask.

  ## Examples

      iex> update_subtask(subtask, %{field: new_value})
      {:ok, %Subtask{}}

      iex> update_subtask(subtask, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subtask(%Subtask{} = subtask, attrs) do
    IO.inspect(subtask, label: "todo In updatetodo")
    IO.inspect(attrs, label: "attrs in updatetodo")
    subtask
    |> Subtask.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subtask.

  ## Examples

      iex> delete_subtask(subtask)
      {:ok, %Subtask{}}

      iex> delete_subtask(subtask)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subtask(%Subtask{} = subtask) do
    Repo.delete(subtask)
  end
    @doc """
    Returns an `%Ecto.Changeset{}` for tracking subtask changes.

    ## Examples

        iex> change_subtask(subtask)
        %Ecto.Changeset{data: %Subtask{}}

    """
    def change_subtask(%Subtask{} = subtask, attrs \\ %{}) do
      IO.inspect(attrs, label: "Attributes")
      Subtask.changeset(subtask, attrs)
    end
end
