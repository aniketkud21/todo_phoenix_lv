defmodule TodoLv.SubtasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoLv.Subtask` context.
  """

  @doc """
  Generate a subtask.
  """
  def subtask_fixture(attrs \\ %{}) do
    import TodoLv.TodosFixtures
    todo = todo_fixture()

    {:ok, subtask} =
      attrs
      |> Enum.into(%{
        desc: "some desc",
        status: "some status",
        title: "some title",
        todo_id: todo.id
      })
      |> TodoLv.Subtasks.create_subtask()

    # on create it is not preloaded
    TodoLv.Subtasks.get_subtask!(subtask.id)
  end
end
