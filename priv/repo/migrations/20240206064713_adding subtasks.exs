defmodule :"Elixir.TodoLv.Repo.Migrations.Adding subtasks" do
  use Ecto.Migration

  def change do
    create table(:subtasks) do
      add :title, :string
      add :desc, :string
      add :status, :string
    end
  end
end
