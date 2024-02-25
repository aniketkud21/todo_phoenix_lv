defmodule :"Elixir.TodoLv.Repo.Migrations.Adding on delete constraints on todo and subtasks" do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE subtasks DROP CONSTRAINT subtasks_todo_id_fkey"

    alter table(:subtasks) do
      modify(:todo_id, references(:todos, on_delete: :delete_all))
    end
  end

  def down do
    execute "ALTER TABLE subtasks DROP CONSTRAINT subtasks_todo_id_fkey"

    alter table(:subtasks) do
      modify(:todo_id, references(:todos, on_delete: :nothing))
    end
  end
end
