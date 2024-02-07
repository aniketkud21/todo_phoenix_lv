defmodule TodoLvWeb.TodoLive.SubtaskFormComponent do
  use TodoLvWeb, :live_component

  alias TodoLv.Subtasks
  alias TodoLv.Todos

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage subtasks of your todos.</:subtitle>
      </.header>

      <.simple_form
        for={@subTaskForm}
        id="subtask-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@subTaskForm[:title]} type="text" label="Title" phx-debounce="500"/>
        <.input field={@subTaskForm[:desc]} type="text" label="Desc" phx-debounce="500"/>
        <.input field={@subTaskForm[:status]} type="select" options={["Hold", "In-Progress", "Complete"]} label="Status"/>

        <:actions>
          <.button phx-disable-with="Saving...">Save Todo</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subtask: subtask} = assigns, socket) do
    IO.inspect(assigns, label: "Assigns of update")
    # todo
    # |> Map.put("user_id" , socket.assigns.current_user.id)

    changeset = Subtasks.change_subtask(subtask)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"subtask" => subtask_params}, socket) do
    # IO.inspect(socket.assigns.current_user)
    IO.inspect(socket.assigns.todo.id, label: "id of todo")
    subtask_params = subtask_params
    |> Map.put_new("todo_id" , socket.assigns.todo.id)
    # IO.inspect(subtask_params, label: "subtask params")

    IO.inspect(subtask_params, label: "In validate")
    changeset =
      socket.assigns.subtask
      |> Subtasks.change_subtask(subtask_params)
      |> Map.put(:action, :validate)

    IO.inspect(changeset, label: "Second call")
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subtask" => subtask_params}, socket) do
    subtask_params = subtask_params
    |> Map.put_new("todo_id" , socket.assigns.todo.id)

    IO.inspect(subtask_params, label: "Socket on save")

    save_todo(socket, socket.assigns.action, subtask_params)
  end

  defp save_todo(socket, :edit, subtask_params) do
    case Subtasks.update_subtask(socket.assigns.subtask, subtask_params) do
      {:ok, subtask} ->
        notify_parent({:saved, subtask})

        {:noreply,
         socket
         |> put_flash(:info, "Subtask updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect("IN ERRRORR")
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_todo(socket, :new, subtask_params) do
    case Subtasks.create_subtask(subtask_params) do
      {:ok, subtask} ->
        notify_parent({:saved, subtask})
        {:noreply,
         socket
         |> put_flash(:info, "Subtask created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :subTaskForm, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
