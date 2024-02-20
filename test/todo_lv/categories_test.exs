defmodule TodoLv.CategoriesTest do
  alias TodoLv.Categories
  use TodoLv.DataCase

  describe "categories" do
    import TodoLv.CategoriesFixtures
    # [{"Study", 1}, {"Household", 2}, {"Work", 3}]
    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Categories.list_categories() == [category]
    end

    test "list_categories_mapping/0 returns all category mappings" do
      category = category_fixture()
      assert Categories.list_categories_mapping() == [{category.name, category.id}]
    end
  end
end

