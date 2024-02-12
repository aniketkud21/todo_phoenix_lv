defmodule :"Elixir.TodoLv.Repo.Migrations.Add User Permissions" do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add(:todo_id, references(:todos))
      add(:user_id, references(:users))
      add(:role_id, references(:roles))
    end
  end
end
