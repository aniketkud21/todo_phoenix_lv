defmodule TodoLv.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoLv.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    import TodoLv.AccountsFixtures
    import TodoLv.CategoriesFixtures

    user = user_fixture()
    category = category_fixture()

    {:ok, todo} =
      attrs
      |> Enum.into(%{
        desc: "some desc",
        like: true,
        status: "some status",
        title: "some title",
        user_id: user.id,
        category_id: category.id
      })
      |> TodoLv.Todos.create_todo()

    TodoLv.Todos.get_todo!(todo.id) # on create it is not preloaded
  end
end
