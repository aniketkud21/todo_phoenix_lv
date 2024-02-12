defmodule TodoLv.Roles.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :role_name, :string
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:role_name])
    |> validate_required([:role_name])
  end
end
