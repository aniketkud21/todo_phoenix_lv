defmodule TodoLvWeb.TodoController do
  alias TodoLv.Accounts
  
  use TodoLvWeb, :controller

  def index(conn, _params) do
    client_api_key = get_req_header(conn, "client-api-key")
    user_api_key = get_req_header(conn, "user-api-key")

    IO.inspect(client_api_key, label: "api resp")
    client = Accounts.get_user_by_api_key(hd(client_api_key))
    user = Accounts.get_user_by_api_key(hd(user_api_key))

    IO.inspect(user.todos, label: "mytodos")

    if(client == nil || user == nil) do
      json(conn, %{error: "Incorrect credentials"})
      # render(conn, :error)
    else
      render(conn, :index, todos: user.todos)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   user = Accounts.get_user!(id)
  #   render(conn, :index, todos: user.todos)
  # end

  def authenticate() do

  end
end
