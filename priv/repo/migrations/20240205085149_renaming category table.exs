defmodule :"Elixir.TodoLv.Repo.Migrations.Renaming category table" do
  use Ecto.Migration

  def change do
    rename table(:category), to: table(:categories)
  end
end
