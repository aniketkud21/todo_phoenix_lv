defmodule TodoLv.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :desc, :string
      add :status, :string
      add :like, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
