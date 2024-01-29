defmodule TodoLv.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :status, :string
    field :title, :string
    field :desc, :string
    field :like, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :desc, :status, :like])
    |> validate_required([:title, :desc, :status, :like])
  end
end
