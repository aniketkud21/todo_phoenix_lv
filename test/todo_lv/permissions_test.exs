defmodule TodoLv.PermissionsTest do
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

    test "get_permission_by_todo_id/1 returns the permission with a given todo_id" do
      permission = permission_fixture()
      assert Permissions.get_permission_by_todo_id!(permission.todo_id)
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
