defmodule TodoLv.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoLv.Category` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "test category"
      })
      |> TodoLv.Categories.create_category()

    category
  end
end
