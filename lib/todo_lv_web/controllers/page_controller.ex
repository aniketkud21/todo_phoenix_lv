defmodule TodoLvWeb.PageController do
  use TodoLvWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def unauth(conn, _params) do
    render(conn, :unauth, layout: false)
  end
end
