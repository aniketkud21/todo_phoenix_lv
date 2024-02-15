defmodule :"Elixir.TodoLv.Repo.Migrations.Add User Permissions" do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add(:todo_id, references(:todos, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:role_id, references(:roles, on_delete: :delete_all))
    end
  end
end
