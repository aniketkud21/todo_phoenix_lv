defmodule :"Elixir.TodoLv.Repo.Migrations.Adding timestamps" do
  use Ecto.Migration

  def change do
    alter table(:subtasks) do
      timestamps(type: :utc_datetime)
    end
  end
end
