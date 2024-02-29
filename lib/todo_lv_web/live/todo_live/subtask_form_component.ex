defmodule TodoLvWeb.TodoLive.SubtaskFormComponent do
  @moduledoc """
  Manages creating and editing subtasks within a todo.

  Key Responsibilities:

  Renders a form for subtask details (title, description, status).
  Handles form submissions (save event) to create or update subtasks.
  Validates form data and provides feedback to the user.
  Interacts with the parent LiveView for updates and broadcasting changes.
  """

  use TodoLvWeb, :live_component

  alias TodoLv.Subtasks

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
        <.input field={@subTaskForm[:title]} type="text" label="Title" phx-debounce="500" />
        <.input field={@subTaskForm[:desc]} type="text" label="Desc" phx-debounce="500" />
        <.input
          field={@subTaskForm[:status]}
          type="select"
          options={["Hold", "In-Progress", "Complete"]}
          label="Status"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Subtask</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subtask: subtask} = assigns, socket) do
    # IO.inspect(assigns, label: "Assigns of update")
    # todo
    # |> Map.put("user_id" , socket.assigns.current_user.id)

    # Appsignal.Logger.info(
    #   "update",
    #   "Assigning changeset of #{subtask.id} for #{assigns.todo_id}"
    # )

    changeset = Subtasks.change_subtask(subtask)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @doc """
  handle_event:
  validate: Validates form data and assigns a changeset for feedback.
  save: Determines the action (create or update) and calls save_subtask.
  save_subtask:
  Handles both creating and updating subtasks.
  Uses Subtasks.create_subtask or Subtasks.update_subtask.
  Sends a message to the parent LiveView with the result.
  Broadcasts updates to subscribed clients.
  Provides feedback through flash messages and navigation.
  """

  @impl true
  def handle_event("validate", %{"subtask" => subtask_params}, socket) do
    subtask_params =
      subtask_params
      |> Map.put_new("todo_id", socket.assigns.todo.id)

    changeset =
      socket.assigns.subtask
      |> Subtasks.change_subtask(subtask_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subtask" => subtask_params}, socket) do
    Appsignal.Logger.info(
      "handle_event",
      "Saving subtask of #{socket.assigns.todo.id}"
    )

    subtask_params =
      subtask_params
      |> Map.put_new("todo_id", socket.assigns.todo.id)

    IO.inspect(subtask_params, label: "Socket on save")

    save_subtask(socket, socket.assigns.action, subtask_params)
  end

  defp save_subtask(socket, :edit, subtask_params) do
    case Subtasks.update_subtask(socket.assigns.subtask, subtask_params) do
      {:ok, subtask} ->
        Appsignal.Logger.info(
          "handle_event",
          "Saving edited subtask #{subtask.id} of #{subtask.todo_id}"
        )
        # notify the status of subtask to main todo
        notify_parent({:saved, subtask, :todo_id, socket.assigns.todo.id})
        # broadcast the edited subtask
        Phoenix.PubSub.broadcast(
          TodoLv.PubSub,
          "subtask:#{socket.assigns.todo.id}",
          {:subtask, subtask}
        )

        IO.inspect("saving with flash")

        {:noreply,
         socket
         |> put_flash(:info, "Subtask updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect("IN ERRRORR")
        Appsignal.Logger.error(
          "handle_event",
          "Failed to Save edited subtask of #{subtask_params.todo_id}"
        )
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subtask(socket, :new, subtask_params) do
    case Subtasks.create_subtask(subtask_params) do
      {:ok, subtask} ->
        Appsignal.Logger.info(
          "handle_event",
          "Saving new subtask #{subtask.id} of #{subtask.todo_id}"
        )
        # notify the status of subtask to main todo
        notify_parent({:saved, subtask, :todo_id, socket.assigns.todo.id})
        # broadcast the new subtask
        Phoenix.PubSub.broadcast(
          TodoLv.PubSub,
          "subtask:#{socket.assigns.todo.id}",
          {:subtask, subtask}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Subtask created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        Appsignal.Logger.error(
          "handle_event",
          "Failed to Save new subtask of #{subtask_params.todo_id}"
        )
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :subTaskForm, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
