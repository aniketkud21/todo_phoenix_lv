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

  @spec changeset(
          {map(), map()}
          | %{
              :__struct__ => atom() | %{:__changeset__ => map(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :desc, :status, :todo_id])
    |> validate_required([:title, :desc, :status, :todo_id])
  end
end
