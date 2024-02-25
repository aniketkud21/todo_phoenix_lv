defmodule TodoLvWeb.TodoLive.ShareFormComponent do
  alias TodoLv.Roles
  alias TodoLv.Accounts
  alias TodoLv.Permissions
  use TodoLvWeb, :live_component

  slot :inner_block

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to share todos.</:subtitle>
      </.header>

      <main class="container">
        <p class="alert alert-info" role="alert" phx-click="lv:clear-flash" phx-value-key="info">
          <%= live_flash(@flash, :info) %>
        </p>
        <p class="alert alert-danger" role="alert" phx-click="lv:clear-flash" phx-value-key="error">
          <%= live_flash(@flash, :error) %>
        </p>
        <%= render_slot(@inner_block) %>
      </main>

      <.table id="users" rows={@streams.permissions}>
        <:col :let={{_id, permission}} label="Name"><%= permission.user.email %></:col>
        <:col :let={{_id, permission}} label="Role"><%= permission.role.role_name %></:col>
        <:action :let={{_id, permission}}>
          <%= if(permission.role.role_name != "Creator") do %>
            <.link
              phx-target={@myself}
              phx-click={JS.push("delete_permission", value: %{id: permission.id})}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          <% end %>
        </:action>
      </.table>

      <.simple_form
        for={@shareform}
        id="share-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="share"
      >
        <.input field={@shareform[:email]} type="text" label="User Email" />
        <.input field={@shareform[:role]} type="select" options={@roles} label="Role" />
        <.button phx-target={@myself}>Share Todo</.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    all_permissions = Permissions.get_permissions_by_todo_id!(assigns.todo.id)
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
  def handle_event("delete_permission", %{"id" => id}, socket) do
    IO.inspect(id)
    permission = Permissions.get_permission!(id)
    {:ok, _} = Permissions.delete_permission(permission)

    Phoenix.PubSub.broadcast(
      TodoLv.PubSub,
      "share:#{permission.todo_id}",
      {:delete_msg, "Your permission to access this todo has been revoked."}
    )

    {:noreply, stream_delete(socket, :permissions, permission)}
  end

  @impl true
  def handle_event("share", %{"email" => email, "role" => role}, socket) do
    # IO.inspect(params, label: "Save params")
    user = Accounts.get_user_by_email(email)
    role = Roles.get_role_by_name!(role)
    IO.inspect(email, label: "email during testing")

    # IO.inspect(%{"todo_id" => socket.assigns.todo.id, "user_id" => Accounts.get_user_by_email(email), "role_id" => Roles.get_role_by_name!(role)}, label: "to save struct")

    # If the user doesnt exist on the app
    if(user == nil || role == nil) do
      IO.inspect("user is nil")

      {:noreply,
       socket
       |> put_flash(:error, "Todo not shared successfully")}
    else
      case Permissions.get_user_todo_permission(user.id, socket.assigns.todo.id) do
        nil ->
          create_permission(socket, socket.assigns.todo.id, user.id, role.id)

        permission ->
          # Check for not editing the permission of creator
          if(permission.role_id == Roles.get_role_by_name!("Creator").id) do
            IO.inspect("Inside edit creator permission")

            {:noreply,
             socket
             |> put_flash(:error, "Can't edit permission")}
          else
            update_permission(socket, permission, socket.assigns.todo.id, user.id, role.id)
          end
      end
    end
  end

  defp update_permission(socket, permission, todo_id, user_id, role_id) do
    case Permissions.update_permission(permission, %{
           "todo_id" => todo_id,
           "user_id" => user_id,
           "role_id" => role_id
         }) do
      {:ok, _permission} ->
        all_permissions = Permissions.get_permissions_by_todo_id!(todo_id)

        if(role_id == Roles.get_role_by_name!("Viewer").id) do
          IO.inspect("broadcasting")

          Phoenix.PubSub.broadcast(
            TodoLv.PubSub,
            "share:#{todo_id}",
            {:update_msg, "Your permissions on this todo have been limited.", :edit_access, false}
          )
        else
          Phoenix.PubSub.broadcast(
            TodoLv.PubSub,
            "share:#{todo_id}",
            {:update_msg, "Your permissions on this todo have been upgraded.", :edit_access, true}
          )
        end

        {:noreply,
         socket
         |> put_flash(:info, "Permission updated successfully")
         |> stream(:permissions, all_permissions, reset: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)

        {:noreply,
         socket
         |> put_flash(:error, "Permission not updated")
         |> assign(shareform: to_form(%{role: "", email: ""}))}
    end
  end

  defp create_permission(socket, todo_id, user_id, role_id) do
    case Permissions.create_permission(%{
           "todo_id" => todo_id,
           "user_id" => user_id,
           "role_id" => role_id
         }) do
      {:ok, _permission} ->
        all_permissions = Permissions.get_permissions_by_todo_id!(todo_id)

        {:noreply,
         socket
         |> put_flash(:info, "Permission shared successfully")
         |> stream(:permissions, all_permissions, reset: true)}

      # stream_insert not working
      # |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)

        {:noreply,
         socket
         |> assign(shareform: to_form(%{role: "", email: ""}))}
    end
  end
end
