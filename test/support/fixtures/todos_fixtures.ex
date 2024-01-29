defmodule TodoLv.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoLv.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        desc: "some desc",
        like: true,
        status: "some status",
        title: "some title"
      })
      |> TodoLv.Todos.create_todo()

    todo
  end
end
