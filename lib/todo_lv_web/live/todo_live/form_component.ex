defmodule TodoLvWeb.TodoLive.FormComponent do
  alias TodoLv.Roles
  alias TodoLv.Permissions
  use TodoLvWeb, :live_component

  alias TodoLv.Todos

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
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" phx-debounce="500"/>
        <.input field={@form[:desc]} type="text" label="Desc" phx-debounce="500"/>
        <.input field={@form[:status]} type="select" options={@options} label="Status"/>
        <.input field={@form[:category_id]} type="select" options={@categories} label="Category"/>
        <.input field={@form[:like]} type="checkbox" label="Like"/>

        <:actions>
          <.button phx-disable-with="Saving...">Save Todo</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{todo: todo} = assigns, socket) do
    # todo
    # |> Map.put("user_id" , socket.assigns.current_user.id)
    # IO.inspect(todo)
    # IO.inspect(assigns, label: "Assigns in new todo")
    changeset = Todos.change_todo(todo)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    todo_params = todo_params
    |> Map.put_new("user_id" , socket.assigns.current_user.id)

    changeset =
      socket.assigns.todo
      |> Todos.change_todo(todo_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    todo_params = todo_params
    |> Map.put_new("user_id" , socket.assigns.current_user.id)

    IO.inspect(todo_params, label: "Socket on save")
    IO.inspect(socket.assigns.action)
    save_todo(socket, socket.assigns.action, todo_params)
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
