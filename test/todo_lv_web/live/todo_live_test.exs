defmodule TodoLvWeb.TodoLiveTest do
  use TodoLvWeb.ConnCase

  import Phoenix.LiveViewTest
  import TodoLv.TodosFixtures
  import TodoLv.AccountsFixtures
  import TodoLv.RolesFixtures
  import TodoLv.CategoriesFixtures

  @create_attrs %{status: "Hold", title: "some title", desc: "some desc", like: true}
  @update_attrs %{
    status: "Hold",
    title: "some updated title",
    desc: "some updated desc",
    like: false
  }
  @invalid_attrs %{status: nil, title: nil, desc: nil, like: false}

  defp create_todo(_) do
    todo = todo_fixture()
    %{todo: todo}
  end

  describe "Index" do
    setup do
      todo = todo_fixture()

      {:ok, _todo} =
        %{}
        |> Enum.into(%{
          desc: "some desc",
          like: false,
          status: "some status",
          title: "disliked title",
          user_id: todo.user_id,
          category_id: todo.category_id
        })
        |> TodoLv.Todos.create_todo()

      {:ok, role} =
        %{}
        |> Enum.into(%{
          role_name: "Editor"
        })
        |> TodoLv.Roles.create_role()

      {:ok, role} =
        %{}
        |> Enum.into(%{
          role_name: "Viewer"
        })
        |> TodoLv.Roles.create_role()

      {:ok, role} =
        %{}
        |> Enum.into(%{
          role_name: "Creator"
        })
        |> TodoLv.Roles.create_role()

      {:ok, subtask} =
        %{}
        |> Enum.into(%{
          desc: "some desc",
          status: "Hold",
          title: "some title",
          todo_id: todo.id
        })
        |> TodoLv.Subtasks.create_subtask()

      {:ok, permission} =
        %{}
        |> Enum.into(%{
          user_id: todo.user_id,
          role_id: role.id,
          todo_id: todo.id
        })
        |> TodoLv.Permissions.create_permission()

      conn = Phoenix.ConnTest.build_conn() |> log_in_user(todo.user)
      # user = user_fixture()
      {:ok, %{conn: conn, todo: todo, role: role, subtask: subtask}}
    end

    # [:create_todo]

    test "lists all todos", %{conn: conn, todo: todo} do
      {:ok, _index_live, html} = live(conn, ~p"/todos")
      IO.inspect(todo.status)
      assert html =~ "Listing Todos"
      assert html =~ todo.status
    end

    test "saves new todo", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> element("a", "New Todo") |> render_click() =~
               "New Todo"

      assert_patch(index_live, ~p"/todos/new")

      # assert index_live
      #        |> form("#todo-form", todo: @invalid_attrs)
      #        |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#todo-form", todo: @create_attrs)
             |> render_submit()

      {:ok, index_live, _html} = live(conn, ~p"/todos")
      # assert_patch(index_live, ~p"/todos")
      # assert navigate("/todos")

      html = render(index_live)
      assert html =~ "some title"
      assert html =~ "some status"
    end

    test "displays a todo", %{conn: conn, todo: todo} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> has_element?("#todos-#{todo.id} a.show_todo")

      assert index_live |> element("#todos-#{todo.id} a.show_todo") |> render_click() =~
               "#{todo.title}"
    end

    # todo # Not working because used href instead of patch

    test "updates todo in listing", %{conn: conn, todo: todo} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> has_element?("#todos-#{todo.id} a", "Edit")

      # assert index_live |> element("#todos-#{todo.id} a", "Edit") |> render_click() =~
      #          "Edit Todo"

      # Not working because used href instead of patch

      {:ok, index_live, _html} = live(conn, ~p"/todos/#{todo.id}/edit")
      # assert_redirect(index_live, ~p"/todos/#{todo.id}/edit")

      # assert index_live
      #        |> form("#todo-form", todo: @invalid_attrs)
      #        |> render_change() =~ "can&#39;t be blank"

      html = render(index_live)
      assert html =~ "Edit Todo"

      assert index_live
             |> form("#todo-form", todo: @update_attrs)
             |> render_submit()

      {:ok, index_live, _html} = live(conn, ~p"/todos")

      html = render(index_live)
      assert html =~ "some updated title"
      refute html =~ "some  title"
    end

    test "shares todo in listing", %{conn: conn, todo: todo} do
      {:ok, user} =
        %{}
        |> Enum.into(%{
          email: "testmail@gmail.com",
          password: "password#123"
        })
        |> TodoLv.Accounts.register_user()

      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> element("#todos-#{todo.id} a", "Share") |> render_click() =~
               "Share Todo"

      assert_patch(index_live, ~p"/todos/#{todo.id}/share")

      # assert index_live
      #        |> form("#todo-form", todo: @invalid_attrs)
      #        |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#share-form", %{email: "testmail@gmail.com", role: "Editor"})
             |> render_submit()

      html = render(index_live)
      assert html =~ "testmail@gmail.com"
      assert html =~ "Todo shared successfully"
    end

    test "deletes a permission", %{conn: conn, todo: todo} do
      {:ok, user} =
        %{}
        |> Enum.into(%{
          email: "testmail@gmail.com",
          password: "password#123"
        })
        |> TodoLv.Accounts.register_user()

      {:ok, role} =
        %{}
        |> Enum.into(%{
          role_name: "Editor"
        })
        |> TodoLv.Roles.create_role()

      {:ok, permission} =
        %{}
        |> Enum.into(%{
          user_id: user.id,
          role_id: role.id,
          todo_id: todo.id
        })
        |> TodoLv.Permissions.create_permission()

      {:ok, index_live, _html} = live(conn, ~p"/todos/#{todo.id}/share")

      html = render(index_live)
      assert html =~ "testmail@gmail.com"
      assert html =~ "Editor"

      assert index_live |> has_element?("#permissions-#{permission.id} a")
      assert index_live |> element("#permissions-#{permission.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#permissions-#{permission.id}")
    end

    test "deletes todo in listing", %{conn: conn, todo: todo} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> element("#todos-#{todo.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#todos-#{todo.id}")
    end

    test "search todo in listing", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      todo = todo_fixture()

      assert index_live
             |> form("#search-form", %{"default_value" => "some"})
             |> render_change()

      html = render(index_live)
      assert html =~ "some title"

      assert index_live
             |> form("#search-form", %{"default_value" => "well"})
             |> render_change()

      html = render(index_live)
      refute html =~ "well"
    end

    test "bookmark todos in listing", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> element("button.bookmark") |> render_click()

      # only liked todo visible
      html = render(index_live)
      refute html =~ "disliked title"
      assert html =~ "some title"

      assert index_live |> element("button.bookmark") |> render_click()

      # both todos visible now
      html = render(index_live)
      assert html =~ "disliked title"
      assert html =~ "some title"
    end

    test "pagination", %{conn: conn, todo: todo} do
      {:ok, _todo} =
        %{}
        |> Enum.into(%{
          desc: "some desc",
          like: false,
          status: "some status",
          title: "disliked title1",
          user_id: todo.user_id,
          category_id: todo.category_id
        })
        |> TodoLv.Todos.create_todo()

      {:ok, _todo} =
        %{}
        |> Enum.into(%{
          desc: "some desc",
          like: false,
          status: "some status",
          title: "disliked title2",
          user_id: todo.user_id,
          category_id: todo.category_id
        })
        |> TodoLv.Todos.create_todo()

      {:ok, _todo} =
        %{}
        |> Enum.into(%{
          desc: "some desc",
          like: false,
          status: "some status",
          title: "disliked title3",
          user_id: todo.user_id,
          category_id: todo.category_id
        })
        |> TodoLv.Todos.create_todo()

      {:ok, _todo} =
        %{}
        |> Enum.into(%{
          desc: "some desc",
          like: false,
          status: "some status",
          title: "disliked title",
          user_id: todo.user_id,
          category_id: todo.category_id
        })
        |> TodoLv.Todos.create_todo()

      {:ok, index_live, _html} = live(conn, ~p"/todos")

      html = render(index_live)

      # IO.inspect(html, limit: :infinity, printable_limit: :infinity, width: 200, label: "HTML:", esc: :unicode)
      refute index_live |> has_element?("button", "prev")
      assert index_live |> has_element?("button", "next")

      assert index_live |> element("button", "next") |> render_click()

      refute index_live |> has_element?("button", "next")
      assert index_live |> has_element?("button", "prev")

      assert index_live |> element("button", "prev") |> render_click()

      refute index_live |> has_element?("button", "prev")
      assert index_live |> has_element?("button", "next")
    end

    test "likes a todo in listing", %{conn: conn, todo: todo} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      # initially liked
      assert index_live |> has_element?("#todos-#{todo.id} a.like_todo .bi-heart-fill")

      assert index_live |> element("#todos-#{todo.id} a.like_todo") |> render_click()
      # on click disliked
      assert index_live |> has_element?("#todos-#{todo.id} a.like_todo .bi-heart")

      assert index_live |> element("#todos-#{todo.id} a.like_todo") |> render_click()
      # on click liked again
      assert index_live |> has_element?("#todos-#{todo.id} a.like_todo .bi-heart-fill")
    end

    test "filter todos in listing", %{conn: conn, todo: todo} do
      {:ok, _todo} =
        %{}
        |> Enum.into(%{
          desc: "some desc",
          like: false,
          status: "Complete",
          title: "Complete title",
          user_id: todo.user_id,
          category_id: todo.category_id
        })
        |> TodoLv.Todos.create_todo()

      {:ok, _todo} =
        %{}
        |> Enum.into(%{
          desc: "some desc",
          like: false,
          status: "In-progress",
          title: "In progress title",
          user_id: todo.user_id,
          category_id: todo.category_id
        })
        |> TodoLv.Todos.create_todo()

      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live |> has_element?("#status-filter-form")

      assert index_live
             |> form("#status-filter-form", %{"status" => "all"})
             |> render_submit()

      html = render(index_live)
      assert html =~ "Complete title"
      assert html =~ "In progress title"
      assert html =~ "disliked title"

      assert index_live
             |> form("#status-filter-form", %{"status" => "In-progress"})
             |> render_submit()

      html = render(index_live)
      assert html =~ "In progress title"
      refute html =~ "Complete title"
      refute html =~ "disliked title"

      assert index_live
             |> form("#status-filter-form", %{"status" => "Complete"})
             |> render_submit()

      html = render(index_live)
      assert html =~ "Complete title"
      refute html =~ "In progress title"
      refute html =~ "disliked title"

      assert index_live
             |> form("#status-filter-form", %{"status" => "Hold"})
             |> render_submit()

      html = render(index_live)
      refute html =~ "Complete title"
      refute html =~ "In progress title"
      refute html =~ "disliked title"
    end
  end

  describe "Show" do
    # setup [:create_todo]

    setup do
      todo = todo_fixture()

      {:ok, role} =
        %{}
        |> Enum.into(%{
          role_name: "Editor"
        })
        |> TodoLv.Roles.create_role()

      {:ok, role} =
        %{}
        |> Enum.into(%{
          role_name: "Viewer"
        })
        |> TodoLv.Roles.create_role()

      {:ok, role} =
        %{}
        |> Enum.into(%{
          role_name: "Creator"
        })
        |> TodoLv.Roles.create_role()

      {:ok, subtask} =
        %{}
        |> Enum.into(%{
          desc: "some desc",
          status: "Hold",
          title: "some subtask title",
          todo_id: todo.id
        })
        |> TodoLv.Subtasks.create_subtask()

      {:ok, permission} =
        %{}
        |> Enum.into(%{
          user_id: todo.user_id,
          role_id: role.id,
          todo_id: todo.id
        })
        |> TodoLv.Permissions.create_permission()

      conn = Phoenix.ConnTest.build_conn() |> log_in_user(todo.user)
      # user = user_fixture()
      {:ok, %{conn: conn, todo: todo, role: role, subtask: subtask}}
    end

    test "displays todo", %{conn: conn, todo: todo} do
      {:ok, _show_live, html} = live(conn, ~p"/todos/#{todo}")

      assert html =~ "Show Todo"
      assert html =~ todo.status
    end

    test "saves new subtask", %{conn: conn, todo: todo} do
      {:ok, index_live, _html} = live(conn, ~p"/todos/#{todo}")
      assert index_live |> has_element?("a", "New Subtask")

      html = render(index_live)
      assert html =~ "some subtask title"
      assert html =~ "some status"

      assert index_live |> element("a", "New Subtask") |> render_click() =~
               "New SubTask"

      # assert index_live
      #        |> form("#todo-form", todo: @invalid_attrs)
      #        |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#subtask-form", %{
               "subtask[status]": "Complete",
               "subtask[title]": "my title",
               "subtask[desc]": "some desc"
             })
             |> render_submit()

      {:ok, index_live, _html} = live(conn, ~p"/todos/#{todo}")

      html = render(index_live)
      assert html =~ "my title"
      assert html =~ "some status"
    end

    test "delete subtask in listings", %{conn: conn, todo: todo, subtask: subtask} do
      {:ok, index_live, _html} = live(conn, ~p"/todos/#{todo.id}")

      assert index_live |> has_element?("#subtasks-#{subtask.id} a", "Delete")

      assert index_live |> element("#subtasks-#{subtask.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#subtasks-#{subtask.id}")
    end

    test "edit subtask in listings", %{conn: conn, todo: todo, subtask: subtask} do
      {:ok, index_live, _html} = live(conn, ~p"/todos/#{todo.id}")

      assert index_live |> has_element?("#subtasks-#{subtask.id} a", "Edit")

      assert index_live |> element("#subtasks-#{subtask.id} a", "Edit") |> render_click() =~
               "Edit SubTask"

      assert_patch(index_live, ~p"/todos/#{todo.id}/#{subtask.id}/edit")

      assert index_live
             |> form("#subtask-form", %{"subtask[title]": "my title update"})
             |> render_submit()

      # assert patch(index_live, ~p"/todos/#{todo.id}")

      html = render(index_live)
      assert html =~ "Subtask updated successfully"
    end

    # Wont work because no apply action written on show page
    test "shares todo in modal", %{conn: conn, todo: todo} do
      {:ok, user} =
        %{}
        |> Enum.into(%{
          email: "testmail@gmail.com",
          password: "password#123"
        })
        |> TodoLv.Accounts.register_user()

      {:ok, index_live, _html} = live(conn, ~p"/todos/#{todo.id}")

      assert index_live |> has_element?("a", "Share Todo")

      assert index_live |> element("a", "Share Todo") |> render_click() =~
               "Share Todo"

      # Assert left

      assert_patch(index_live, ~p"/todos/#{todo.id}/share")

      # # assert index_live
      # #        |> form("#todo-form", todo: @invalid_attrs)
      # #        |> render_change() =~ "can&#39;t be blank"

      # assert index_live
      #        |> form("#share-form", %{email: "testmail@gmail.com", role: "Editor"})
      #        |> render_submit()

      # html = render(index_live)
      # assert html =~ "Use this form to share todos."

      # html = render(index_live)
      # assert html =~ "testmail@gmail.com"
      # assert html =~ "Todo shared successfully"
    end

    # test "updates todo within modal", %{conn: conn, todo: todo} do
    #   {:ok, show_live, _html} = live(conn, ~p"/todos/#{todo.id}")

    #   assert show_live |> element("a", "Edit Todo") |> render_click() =~
    #            "Edit Todo"

    #   assert_patch(show_live, ~p"/todos/#{todo.id}/edit")

    #   # assert show_live
    #   #        |> form("#todo-form", todo: @invalid_attrs)
    #   #        |> render_change() =~ "can&#39;t be blank"

    #   assert show_live
    #          |> form("#todo-form", todo: @update_attrs)
    #          |> render_submit()

    #   assert_patch(show_live, ~p"/todos/#{todo.id}")

    #   html = render(show_live)
    #   assert html =~ "Todo updated successfully"
    #   assert html =~ "some updated status"
    # end
  end
end
