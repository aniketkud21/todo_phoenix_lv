defmodule TodoLvWeb.TodoLive.FormComponent do
  alias TodoLv.Roles
  alias TodoLv.Permissions
  use TodoLvWeb, :live_component

  alias TodoLv.Todos

  on_mount {TodoLvWeb.UserAuth, :check_edit_permission}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage todo records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="todo-form"
        phx-target={@myself}
        phx-submit="save"
        phx-hook="ChannelJoin"
      >
        <.input field={@form[:title]} type="text" id="title-input" label="Title" phx-debounce="500"/>
        <.input field={@form[:desc]} type="text" id="desc-input" label="Desc" phx-debounce="500"/>
        <.input field={@form[:status]} type="select" id="status-input" options={@options} label="Status"/>
        <.input field={@form[:category_id]} type="select" id="category-input" options={@categories} label="Category"/>
        <.input field={@form[:like]} type="checkbox" id="like-input" label="Like"/>

        <:actions>
          <.button phx-disable-with="Saving...">Save Todo</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    IO.inspect(socket, label: "Inside component")
    {:ok, socket}
  end

  @impl true
  def update(%{todo: todo} = assigns, socket) do
    # todo
    # |> Map.put("user_id" , socket.assigns.current_user.id)
    # IO.inspect(todo)
    #IO.inspect(assigns, label: "Assigns in new todo")

    cond do
      todo.id == nil ->
        changeset = Todos.change_todo(todo)
        {:ok,
        socket
        |> assign(assigns)
        |> assign_form(changeset)}
      check_permission(assigns.current_user.id, todo.id) == true ->
        changeset = Todos.change_todo(todo)

        {:ok,
        socket
        |> assign(assigns)
        |> assign(:creator_id, todo.user_id)
        |> assign_form(changeset)}
      check_permission(assigns.current_user.id, todo.id) == false ->
        {:ok,
         socket
         |> put_flash(:error, "Unauthorized")
         |> push_navigate(to: ~p"/unauthorized")}
    end
  end

  defp check_permission(user_id, todo_id) do
    permission = Permissions.get_user_todo_permission(user_id, todo_id)
    cond do
      permission.role_id==3 || permission.role_id==1 -> true
      true -> false
    end
  end

  # @impl true
  # def handle_event("validate", %{"todo" => todo_params}, socket) do
  #   todo_params = todo_params
  #   |> Map.put_new("user_id" , socket.assigns.current_user.id)

  #   changeset =
  #     socket.assigns.todo
  #     |> Todos.change_todo(todo_params)
  #     |> Map.put(:action, :validate)

  #   {:noreply, assign_form(socket, changeset)}
  # end
  @impl true
  def handle_event("save", %{"todo" => todo_params}, socket) do
    IO.inspect(todo_params, label: "Socket on save")
    IO.inspect(socket.assigns.action)
    if(socket.assigns.action == :edit) do
      todo_edit_params = todo_params
      |> Map.put_new("user_id" , socket.assigns.creator_id)
      save_todo(socket, socket.assigns.action, todo_edit_params)
    else
      todo_new_params = todo_params
      |> Map.put_new("user_id" , socket.assigns.current_user.id)
      save_todo(socket, socket.assigns.action, todo_new_params)
    end
  end

  defp save_todo(socket, :edit, todo_params) do
    IO.inspect("ssp")
    case Todos.update_todo(socket.assigns.todo, todo_params) do
      {:ok, todo} ->
        notify_parent({:saved, todo})

        {:noreply,
         socket
         |> put_flash(:info, "Todo updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_todo(socket, :new, todo_params) do
    case Todos.create_todo(todo_params) do
      {:ok, todo} ->
        Permissions.create_permission(%{"todo_id" => todo.id, "user_id" => socket.assigns.current_user.id, "role_id" => Roles.get_role_by_name!("Creator").id})

        notify_parent({:saved, todo})
        IO.inspect(socket)
        {:noreply,
         socket
         |> put_flash(:info, "Todo created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    socket
    |> assign(:form, to_form(changeset))
    |> assign(:subtaskform, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
