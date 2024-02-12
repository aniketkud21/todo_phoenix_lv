defmodule TodoLvWeb.TodoLive.ShareFormComponent do
  use TodoLvWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to share todos.</:subtitle>
      </.header>

      <.simple_form
        for={@shareform}
        id="share-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@shareform[:status]} type="select" options={["Viewer", "Editor"]} label="Status"/>
        <button>Share Todo</button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    # # todo
    # # |> Map.put("user_id" , socket.assigns.current_user.id)
    # IO.inspect(todo)
    # IO.inspect(assigns, label: "Assigns in new todo")

    # changeset = Todos.change_todo(todo)
    IO.inspect(assigns, label: "Shareform")
    # IO.inspect(socket.assigns.todo)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(shareform: to_form(%{status: "Viewer"}))}
  end

  @impl true
  def handle_event("validate", params, socket) do

    # %{"_target" => ["status"], "status" => "Viewer"}

    # todo_params = todo_params
    # |> Map.put_new("user_id" , socket.assigns.current_user.id)

    # changeset =
    #   socket.assigns.todo
    #   |> Todos.change_todo(todo_params)
    #   |> Map.put(:action, :validate)

    IO.inspect(params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", params, socket) do
    # todo_params = todo_params
    # |> Map.put_new("user_id" , socket.assigns.current_user.id)

    # IO.inspect(todo_params, label: "Socket on save")
    # IO.inspect(socket.assigns.action)
    IO.inspect(params, label: "Save params")
    {:noreply,
    socket
    |> put_flash(:info, "Todo shared successfully")
    |> push_navigate(to: socket.assigns.navigate)}
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
