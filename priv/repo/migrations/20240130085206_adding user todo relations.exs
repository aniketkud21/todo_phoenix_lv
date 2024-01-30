defmodule :"Elixir.TodoLv.Repo.Migrations.Adding user todo relations" do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add(:user_id, references(:users, on_delete: :delete_all))
    end
  end
end
