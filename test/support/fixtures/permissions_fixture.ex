defmodule TodoLv.PermissionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoLv.Permission` context.
  """

  @doc """
  Generate a permission.
  """
  def permission_fixture(attrs \\ %{}) do
    import TodoLv.AccountsFixtures
    import TodoLv.RolesFixtures
    import TodoLv.TodosFixtures

    user = user_fixture()
    role = role_fixture()
    todo = todo_fixture()

    {:ok, permission} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        role_id: role.id,
        todo_id: todo.id
      })
      |> TodoLv.Permissions.create_permission()

    TodoLv.Permissions.get_permission!(permission.id)
    # permission
  end


end
