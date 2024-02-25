defmodule TodoLv.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :status, :string
    field :title, :string
    field :desc, :string
    field :like, :boolean, default: false
    belongs_to :user, TodoLv.Accounts.User
    belongs_to :category, TodoLv.Categories.Category
    has_many :subtasks, TodoLv.Subtasks.Subtask

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :desc, :status, :like, :user_id, :category_id])
    |> validate_required([:title, :desc, :status, :like, :user_id, :category_id])
  end
end
