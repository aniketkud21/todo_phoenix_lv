defmodule TodoLv.Permissions do
  @moduledoc """
  The Permissions context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Repo

  alias TodoLv.Permissions.Permission

  @doc """
  Gets a specific permission by its ID.

  Raises `Ecto.NoResultsError` if the permission does not exist.

  ## Examples

  iex> MyModule.get_permission!(123)
  # Returns the %Permission{} struct for the permission with ID 123,
  # preloaded with its associated role and user

  iex> MyModule.get_permission!(456)
  # Raises `Ecto.NoResultsError` if no permission with ID 456 exists

  ## Return value

  - A %Permission{} struct with the specified ID:
      - Includes attributes like `action`, `resource`, etc.
      - Preloaded with:
          - The associated %Role{} struct
          - The associated %User{} struct (if applicable)

  """
  def get_permission!(id) do
    Repo.get!(Permission, id) |> Repo.preload(:role) |> Repo.preload(:user)
  end

  @doc """
  Fetches the specific permission a user has on a particular todo.

  Raises `Ecto.NoResultsError` if no such permission exists or the user/todo combination is invalid.

  ## Arguments

  - `user_id` (integer): The unique identifier of the user.
  - `todo_id` (integer): The unique identifier of the todo.

  ## Return value

  - A %Permission{} struct representing the user's permission on the todo, preloaded with its associated role.

  ## Note

  - If the user doesn't have any permission for the specified todo, `nil` is returned.

  ## Examples

  iex> MyModule.get_user_todo_permission(1, 2)
  # Returns the %Permission{} for user 1 on todo 2, or nil if none exists

  iex> MyModule.get_user_todo_permission(3, 4)
  # Raises `Ecto.NoResultsError` if user 3 has no permission on todo 4 or either ID is invalid

  """
  def get_user_todo_permission(user_id, todo_id) do
    Repo.get_by!(Permission, user_id: user_id, todo_id: todo_id) |> Repo.preload(:role)
  end

  @doc """
  Gets a specific permission by its todo_id.

  Raises `Ecto.NoResultsError` if the permission does not exist.

  ## Examples

  iex> MyModule.get_permission!(123)
  # Returns the %Permission{} struct for the permission with todo_id 123,
  # preloaded with its associated role and user

  iex> MyModule.get_permission!(456)
  # Raises `Ecto.NoResultsError` if no permission with todo_id 456 exists

  ## Return value

  - A %Permission{} struct with the specified todo_id:
      - Includes attributes like `action`, `resource`, etc.
      - Preloaded with:
          - The associated %Role{} struct
          - The associated %User{} struct (if applicable)

  """
  def get_permission_by_todo_id!(todo_id) do
    permissions = from p in Permission,
      where: p.todo_id == ^todo_id,
      select: p

    Repo.all(permissions) |> Repo.preload(:role) |> Repo.preload(:user)
  end

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
  Deletes a specified permission.

  **Preconditions:**

  - The provided `permission` argument must be a valid %Permission{} struct.

  **Returns:**

  - `:ok` if the permission is successfully deleted.
  - An `Ecto.StaleDataError` if the permission has already been deleted by another process.

  ## Examples

  iex> MyModule.delete_permission(%Permission{id: 123})
  # Returns :ok if the permission with ID 123 is deleted

  iex> MyModule.delete_permission(%Permission{id: 456})
  # Raises `Ecto.StaleDataError` if the permission with ID 456 is already deleted

  """
  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end
end
