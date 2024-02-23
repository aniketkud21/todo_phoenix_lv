defmodule TodoLv.PermissionsTest do
  alias TodoLv.Permissions.Permission
  alias TodoLv.Permissions
  use TodoLv.DataCase

  describe "permissions" do
    import TodoLv.PermissionsFixtures

    test "get_permission/1 returns the permission with given id" do
      permission = permission_fixture()
      assert Permissions.get_permission!(permission.id) == permission
    end

    test "get_user_todo_permission/2 returns the permission with given user and todo id" do
      permission = permission_fixture()
      assert Permissions.get_user_todo_permission(permission.user_id, permission.todo_id) == permission
    end

    # # assert to be written
    # test "get_permissions_by_todo_id/1 returns the permissions with a given todo_id" do
    #   permission = permission_fixture()
    #   assert Permissions.get_permissions_by_todo_id!(permission.todo_id)
    # end

    # # to be written
    # test "update_permission/2 with valid data updates the permission" do
    #   permission = permission_fixture()
    #   update_attrs = %{user_id: 3, todo_id: 6, role_id: 2}

    #   assert {:ok, %Permission{} = permission} = Permissions.update_permission(permission, update_attrs)
    #   assert permission.role_id == 2
    # end

    test "delete_permission/1 deletes the permission" do
      permission = permission_fixture()
      assert {:ok, %Permission{}} = Permissions.delete_permission(permission)
      assert_raise Ecto.NoResultsError, fn -> Permissions.get_permission!(permission.id) end
    end
  end
end

# defmodule TodoLv.CategoriesTest do
#   alias TodoLv.Categories
#   use TodoLv.DataCase

#   describe "categories" do
#     import TodoLv.CategoriesFixtures
#     # [{"Study", 1}, {"Household", 2}, {"Work", 3}]
#     test "list_categories/0 returns all categories" do
#       category = category_fixture()
#       assert Categories.list_categories() == [category]
#     end

#     test "list_categories_mapping/0 returns all category mappings" do
#       category = category_fixture()
#       assert Categories.list_categories_mapping() == [{category.name, category.id}]
#     end
#   end
# end
