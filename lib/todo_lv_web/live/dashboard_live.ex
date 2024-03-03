defmodule TodoLvWeb.DashboardLive do
  alias TodoLv.Accounts
  alias TodoLv.Credits
  use TodoLvWeb, :live_view

  on_mount {TodoLvWeb.UserAuth, :mount_current_user}

  @impl true
  def render(assigns) do
    ~H"""
    <%= @current_user.email %>
    <h1>Dashboard</h1>

    <h2><%= @current_user.api_key %></h2>
    <h2><%= @credit %></h2>
    <h2>History</h2>
    <h2>Time  Creds</h2>
    <h2>12:30  10</h2>
    <.header>Form</.header>
    <.simple_form for={@form} phx-submit="submit">
      <.input
        field={@form[:api_key]}
        type="text"
        id="api-key-input"
        label="Api Key"
        phx-debounce="500"
      />
      <.button>Send</.button>
    </.simple_form>
    """
  end

  @impl true
  def mount(_, _, socket) do
    credits = Credits.get_user_credits(socket.assigns.current_user.id).credits

    {:ok, socket |> assign(:credit, credits) |> assign(:form, to_form(%{api_key: ""}))}
  end

  @impl true
  def handle_event("submit", %{"api_key" => api_key}, socket) do
    IO.inspect(api_key)
    user = Accounts.get_user_by_api_key(api_key)
    if(user == nil) do
      {:noreply, socket |> put_flash(:error, "Invalid Api Key")}
    else
      {:noreply, socket |> put_flash(:info, "todo access granted") |> redirect(to: ~p"/api/todos/#{user.id}")}
    end

  end
end
