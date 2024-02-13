defmodule TodoLv.Permissions do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Repo

  alias TodoLv.Permissions.Permission

  @doc """
  Gets a single permission.

  Raises `Ecto.NoResultsError` if the Permission does not exist.

  ## Examples

      iex> get_permission!(123)
      %Permission{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_permission!(id) do
    Repo.get!(Permission, id) |> Repo.preload(:role) |> Repo.preload(:user)
  end

  def get_permission_by_user_id!(user_id, todo_id) do
    Repo.get_by!(Permission, user_id: user_id, todo_id: todo_id) |> Repo.preload(:role)
  end

  def get_permission_by_todo_id!(todo_id) do
    permissions = from p in Permission,
      where: p.todo_id == ^todo_id,
      select: p

    Repo.all(permissions) |> Repo.preload(:role) |> Repo.preload(:user)
  end

  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end

  #def get_todo!(id), do: Repo.get!(Todo, id) |> Repo.preload(:user) |> Repo.preload(:category) |> Repo.preload(:subtasks)

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
