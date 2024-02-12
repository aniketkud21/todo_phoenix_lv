defmodule TodoLv.Permissions.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    belongs_to :todo, TodoLv.Todos.Todo
    belongs_to :user, TodoLv.Accounts.User
    belongs_to :role, TodoLv.Roles.Role
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:todo_id, :user_id, :role_id])
    |> validate_required([:todo_id, :user_id, :role_id])
  end
end
