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

      iex> list_roles()
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

  @spec get_role_by_name!(any()) :: any()
  @doc """
  Gets a specific role by its name.

  Raises `Ecto.NoResultsError` if the role does not exist.

  ## Examples

  iex> TodoLv.Roles.get_role_by_name!("Creator")
  # Returns the %Role{} struct for the "Creator" role

  iex> TodoLv.Roles.get_role_by_name!("unknown_role")
  # Raises `Ecto.NoResultsError` if no role named "unknown_role" exists

  """
  def get_role_by_name!(role_name), do: Repo.get_by!(Role, role_name: role_name)

  @doc """
  Creates a role.

  ## Note -- Only for tests

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end
end
