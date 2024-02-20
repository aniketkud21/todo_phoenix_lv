defmodule TodoLv.Categories do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoLv.Repo

  alias TodoLv.Categories.Category

  @doc """
  Retrieves a list of all categories from the database, preloaded with their associated todos.

  ## Return value

  A list of %Category{} structs, each preloaded with a list of associated %Todo{} structs.

  ## Note

  - The categories returned may be unordered.
  - The number of preloaded todos per category may vary.

  ## Examples

  iex> TodoLv.Categories.list_categories()
  # Returns a list of %Category{} structs, each with preloaded %Todo{} structs

"""
  def list_categories do
    Repo.all(Category) |> Repo.preload(:todos)
  end

  @doc """
  Returns a list of key-value pairs mapping category names to their corresponding IDs.

  **Please note:** In this specific implementation, the output is always ordered alphabetically by category name, resulting in a fixed list of `[{"Study", 1}, {"Household", 2}, {"Work", 3}]`. This might not be the case in other scenarios where the `Category` table contains different data or the sorting logic changes.

  This is useful for creating dropdown menus, form selections, or other situations where you need to display both the category name and its ID.

  ## Return value

  A list of tuples, where each tuple contains:

  * The category name (String)
  * The category ID (Integer)

  ## Example

      iex> list_categories_mapping()
      [{"Study", 1}, {"Household", 2}, {"Work", 3}]

  """
  def list_categories_mapping() do
    Repo.all(Category)
    |> Enum.map(&{&1.name, &1.id})
  end

  @doc """
  Creates a category.

  ## Note -- Only for tests

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    IO.inspect(attrs, label: "Attributes in create")
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end
end
