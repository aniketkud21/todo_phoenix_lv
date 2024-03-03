defmodule TodoLv.Credits do
  @moduledoc """
  The Credits context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Credits.Credit
  alias TodoLv.Repo

  @doc """
  Creates a category.

  ## Note -- Only for tests

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credit(attrs \\ %{}) do
    %Credit{}
    |> Credit.changeset(attrs)
    |> Repo.insert()
  end

  def get_user_credits(user_id) do
    Repo.get_by(Credit, user_id: user_id)
  end
end
