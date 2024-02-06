defmodule :"Elixir.TodoLv.Repo.Migrations.Adding relation to subtask" do
  use Ecto.Migration

  def change do
    alter table(:subtasks) do
      add(:todo_id, references(:todos, on_delete: :nothing))
    end
  end
end
