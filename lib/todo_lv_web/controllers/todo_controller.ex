defmodule TodoLvWeb.TodoController do
  alias TodoLv.Todos
  use TodoLvWeb, :controller

  def index(conn, _params) do
    todos = Todos.list_todos()
    render(conn, :index, todos: todos)
  end
end
