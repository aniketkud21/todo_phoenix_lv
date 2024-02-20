defmodule TodoLv.RolesTest do
  alias TodoLv.Roles
  use TodoLv.DataCase

  describe "roles" do

    import TodoLv.RolesFixtures

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Roles.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Roles.get_role!(role.id) == role
    end

    test "get_role_by_name!/1 returns the role with given id" do
      role = role_fixture()
      assert Roles.get_role_by_name!(role.role_name) == role
    end
  end
end
