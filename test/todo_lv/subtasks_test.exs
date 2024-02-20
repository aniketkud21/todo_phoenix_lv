defmodule TodoLv.SubtasksTest do
  alias TodoLv.Subtasks.Subtask
  alias TodoLv.Subtasks
  use TodoLv.DataCase

  describe "subtasks" do
    import TodoLv.SubtasksFixtures
    import TodoLv.TodosFixtures

    @invalid_attrs %{status: nil, title: nil, desc: nil}

    test "list_subtasks/0 returns all subtasks" do
      subtask = subtask_fixture()
      assert Subtasks.list_subtasks() == [subtask]
    end

    test "get_subtask!/1 returns the subtask with given id" do
      subtask = subtask_fixture()
      assert Subtasks.get_subtask!(subtask.id) == subtask
    end

    test "create_subtask/1 with valid data creates a subtask" do
      todo = todo_fixture()
      # subtask = subtask_fixture()

      valid_attrs = %{status: "some status", title: "some title", desc: "some desc", todo_id: todo.id}

      assert {:ok, %Subtask{} = subtask} = Subtasks.create_subtask(valid_attrs)
      assert subtask.status == "some status"
      assert subtask.title == "some title"
      assert subtask.desc == "some desc"
      assert subtask.todo_id == todo.id
    end

    test "create_subtask/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subtasks.create_subtask(@invalid_attrs)
    end

    test "update_subtask/2 with valid data updates the subtask" do
      subtask = subtask_fixture()
      update_attrs = %{status: "some updated status", title: "some updated title", desc: "some updated desc"}

      assert {:ok, %Subtask{} = subtask} = Subtasks.update_subtask(subtask, update_attrs)
      assert subtask.status == "some updated status"
      assert subtask.title == "some updated title"
      assert subtask.desc == "some updated desc"
    end

    test "update_subtask/2 with invalid data returns error changeset" do
      subtask = subtask_fixture()
      assert {:error, %Ecto.Changeset{}} = Subtasks.update_subtask(subtask, @invalid_attrs)
      assert subtask == Subtasks.get_subtask!(subtask.id)
    end

    test "delete_subtask/1 deletes the subtask" do
      subtask = subtask_fixture()
      assert {:ok, %Subtask{}} = Subtasks.delete_subtask(subtask)
      assert_raise Ecto.NoResultsError, fn -> Subtasks.get_subtask!(subtask.id) end
    end

    test "change_subtask/1 returns a subtask changeset" do
      subtask = subtask_fixture()
      assert %Ecto.Changeset{} = Subtasks.change_subtask(subtask)
    end
  end
end
