defmodule TodoLv.Credits.Credit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credits" do
    field :credits, :integer
    belongs_to :user, TodoLv.Accounts.User
  end

  @doc false
  def changeset(credit, attrs) do
    credit
    |> cast(attrs, [:credits, :user_id])
    |> validate_required([:credits, :user_id])
  end
end
