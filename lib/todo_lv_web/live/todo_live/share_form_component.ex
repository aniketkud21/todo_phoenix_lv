defmodule TodoLvWeb.TodoLive.ShareFormComponent do
  alias TodoLv.Roles
  alias TodoLv.Accounts
  alias TodoLv.Permissions
  use TodoLvWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to share todos.</:subtitle>
      </.header>

      <.table
        id="users"
        rows={@streams.permissions}
      >
        <:col :let={{_id, permission}} label="Name"><%= permission.user.email %></:col>
        <:col :let={{_id, permission}} label="Role"><%= permission.role.role_name %></:col>
        <:action :let={{id, permission}}>
          <.link
            phx-click={JS.push("deletepermission", value: %{id: permission.id})}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>

      <.simple_form
        for={@shareform}
        id="share-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="share"
      >
        <.input field={@shareform[:email]} type="text" label="User Email"/>
        <.input field={@shareform[:role]} type="select" options={@roles} label="Role"/>
        <.button>Share Todo</.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    all_permissions = Permissions.get_permission_by_todo_id!(assigns.todo.id)
    IO.inspect(all_permissions)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(shareform: to_form(%{role: "", email: ""}))
     |> stream(:permissions, all_permissions)}
  end

  @impl true
  def handle_event("validate", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  @impl true
  def handle_event("deletepermission", %{"id" => id}, socket) do
    IO.inspect(id)
    permission = Permissions.get_permission!(id)
    {:ok, _} = Permissions.delete_permission(permission)

    {:noreply, stream(socket, :permissions, permission, reset: true)}
  end

  @impl true
  def handle_event("share", %{"email" => email, "role" => role}, socket) do
    #IO.inspect(params, label: "Save params")
    user_id = Accounts.get_user_by_email(email)
    role_id = Roles.get_role_by_name!(role)

    IO.inspect(%{"todo_id" => socket.assigns.todo.id, "user_id" => Accounts.get_user_by_email(email), "role_id" => Roles.get_role_by_name!(role)}, label: "to save struct")

    if(user_id == nil || role_id == nil) do
      {:noreply,
        socket
        |> put_flash(:error, "Todo not shared successfully")
        |> push_navigate(to: socket.assigns.navigate)}
    else
      case Permissions.create_permission(%{"todo_id" => socket.assigns.todo.id, "user_id" => Accounts.get_user_by_email(email).id, "role_id" => Roles.get_role_by_name!(role).id}) do
        {:ok, _permission} ->
          {:noreply,
          socket
          |> put_flash(:info, "Todo shared successfully")
          |> push_navigate(to: socket.assigns.navigate)}

        {:error, %Ecto.Changeset{} = changeset} ->
          IO.inspect(changeset)
          {:noreply,
            socket
            |> assign(shareform: to_form(%{role: "", email: ""}))}
      end
    end
  end
end

# defmodule TodoLvWeb.TodoLive.FormComponent do
#   use TodoLvWeb, :live_component

#   alias TodoLv.Todos


#   def handle_event("save", %{"todo" => todo_params}, socket) do
#     todo_params = todo_params
#     |> Map.put_new("user_id" , socket.assigns.current_user.id)

#     IO.inspect(todo_params, label: "Socket on save")
#     IO.inspect(socket.assigns.action)
#     save_todo(socket, socket.assigns.action, todo_params)
#   end

#   defp save_todo(socket, :edit, todo_params) do
#     IO.inspect("ssp")
#     case Todos.update_todo(socket.assigns.todo, todo_params) do
#       {:ok, todo} ->
#         notify_parent({:saved, todo})

#         {:noreply,
#          socket
#          |> put_flash(:info, "Todo updated successfully")
#          |> push_navigate(to: socket.assigns.navigate)}

#       {:error, %Ecto.Changeset{} = changeset} ->
#         {:noreply, assign_form(socket, changeset)}
#     end
#   end

#   defp save_todo(socket, :new, todo_params) do
#     case Todos.create_todo(todo_params) do
#       {:ok, todo} ->
#         notify_parent({:saved, todo})
#         IO.inspect(socket)
#         {:noreply,
#          socket
#          |> put_flash(:info, "Todo created successfully")
#          |> push_navigate(to: socket.assigns.navigate)}

#       {:error, %Ecto.Changeset{} = changeset} ->
#         {:noreply, assign_form(socket, changeset)}
#     end
#   end

#   defp assign_form(socket, %Ecto.Changeset{} = changeset) do
#     socket
#     |> assign(:form, to_form(changeset))
#     |> assign(:subtaskform, to_form(changeset))
#   end

#   defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
# end
