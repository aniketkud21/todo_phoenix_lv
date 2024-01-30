defmodule TodoLv.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:title, :status],
    sortable: [:title, :status],
    default_limit: 4
  }

  schema "todos" do
    field :status, :string
    field :title, :string
    field :desc, :string
    field :like, :boolean, default: false
    belongs_to :user, TodoLv.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :desc, :status, :like])
    |> validate_required([:title, :desc, :status, :like])
  end
end
