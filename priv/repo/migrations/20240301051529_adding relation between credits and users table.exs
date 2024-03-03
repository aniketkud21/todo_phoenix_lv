defmodule :"Elixir.TodoLv.Repo.Migrations.Adding relation between credits and users table" do
  use Ecto.Migration

  def change do
    alter table(:credits) do
      add(:user_id, references(:users, on_delete: :delete_all))
    end
  end
end
