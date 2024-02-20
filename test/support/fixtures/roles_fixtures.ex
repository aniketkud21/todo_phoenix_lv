defmodule TodoLv.RolesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoLv.Roles` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        role_name: "some_role"
      })
      |> TodoLv.Roles.create_role()
    role
  end
end
