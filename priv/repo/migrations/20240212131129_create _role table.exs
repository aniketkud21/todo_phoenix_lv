defmodule :"Elixir.TodoLv.Repo.Migrations.Create Role table" do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :role_name, :string
    end
  end
end
