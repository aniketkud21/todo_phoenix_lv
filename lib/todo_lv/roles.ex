defmodule TodoLv.Roles do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Repo

  alias TodoLv.Roles.Role

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roless()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id), do: Repo.get!(Role, id)

  @doc """
  Gets a role by role_name.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role_by_name!(123)
      %Role{}

      iex> get_role_by_name!(456)
      ** (Ecto.NoResultsError)

  """

  def get_role_by_name!(role_name), do: Repo.get_by!(Role, role_name: role_name)
end
