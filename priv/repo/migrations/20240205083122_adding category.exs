defmodule :"Elixir.TodoLv.Repo.Migrations.Adding category" do
  use Ecto.Migration

  def change do
    create table(:category) do
      add :name, :string
    end

    alter table(:todos) do
      add(:category_id, references(:category, on_delete: :nothing))
    end
  end
end
