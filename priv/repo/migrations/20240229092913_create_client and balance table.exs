defmodule :"Elixir.TodoLv.Repo.Migrations.CreateClient and balance table" do
  use Ecto.Migration

  def change do
    create table(:credits) do
      add :credits, :integer
    end
  end
end
