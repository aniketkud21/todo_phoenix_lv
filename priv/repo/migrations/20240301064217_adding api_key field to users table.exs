defmodule :"Elixir.TodoLv.Repo.Migrations.Adding apiKey field to users table" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:api_key, :string)
    end
  end
end
