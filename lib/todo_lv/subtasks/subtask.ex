defmodule TodoLv.Subtasks.Subtask do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subtasks" do
    field :status, :string
    field :title, :string
    field :desc, :string
    belongs_to :todo, TodoLv.Todos.Todo

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :desc, :status, :todo_id])
    |> validate_required([:title, :desc, :status, :todo_id])
  end
end
