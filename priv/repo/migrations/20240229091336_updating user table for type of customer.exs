defmodule :"Elixir.TodoLv.Repo.Migrations.Updating user table for type of customer" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:user_type, :string)
    end
  end
end
