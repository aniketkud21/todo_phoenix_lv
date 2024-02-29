defmodule TodoLvWeb.TodoLive.FormComponent do
  @moduledoc """
  Provides a reusable LiveComponent for managing todo creation and editing.

  Key Responsibilities:

  Renders a form for todo details (title, description, status, category, like).
  Handles form submissions (save event) to create or update todos.
  Validates form data and provides feedback to the user.
  Interacts with parent LiveView for navigation and data updates.
  """

  alias TodoLv.Roles
  alias TodoLv.Permissions
  use TodoLvWeb, :live_component

  alias TodoLv.Todos

  @impl true
  def render(assigns) do
    IO.inspect(assigns, label: "in render")

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
        <.input field={@form[:title]} type="text" id="title-input" label="Title" phx-debounce="500" />
        <.input field={@form[:desc]} type="text" id="desc-input" label="Desc" phx-debounce="500" />
        <.input
          field={@form[:status]}
          type="select"
          id="status-input"
          options={@options}
          label="Status"
        />
        <.input
          field={@form[:category_id]}
          type="select"
          id="category-input"
          options={@categories}
          label="Category"
        />
        <.input field={@form[:like]} type="checkbox" id="like-input" label="Like" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Todo</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{todo: todo} = assigns, socket) do
    IO.inspect(assigns)
    IO.inspect(socket)

    Appsignal.Logger.info(
      "update",
      "Assigning changeset #{todo.id} by #{assigns.creator_id}"
    )

    IO.inspect(todo, label: "Checking changeset of new todo")
    changeset = Todos.change_todo(todo)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}

    # todo
    # |> Map.put("user_id" , socket.assigns.current_user.id)
    # IO.inspect(todo)
    # IO.inspect(assigns, label: "Assigns in new todo")
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

  @doc """
  Handles user interactions with the form:

  save: Validates and saves form data to create or update a todo.

  Actions:

  Validates form data using the Todos.change_todo function.
  Creates a new todo or updates an existing one based on socket.assigns.action.
  Sends a {:saved, todo} message to the parent LiveView on success.
  Provides feedback to the user through flash messages and navigation.
  """

  @impl true
  def handle_event("save", %{"todo" => todo_params}, socket) do
    Appsignal.Logger.info(
      "update",
      "Saving todo by #{socket.assigns.creator_id}"
    )

    IO.inspect(todo_params, label: "Socket on save")
    IO.inspect(socket.assigns)
    # if(socket.assigns.action == :edit) do
    #   todo_edit_params = todo_params
    #   |> Map.put_new("user_id" , socket.assigns.creator_id)
    #   save_todo(socket, socket.assigns.action, todo_edit_params)
    # else
    #   todo_new_params = todo_params
    #   |> Map.put_new("user_id" , socket.assigns.current_user.id)
    #   save_todo(socket, socket.assigns.action, todo_new_params)
    # end

    todo_params =
      todo_params
      |> Map.put_new("user_id", socket.assigns.creator_id)

    save_todo(socket, socket.assigns.action, todo_params)
  end

  defp save_todo(socket, :edit, todo_params) do
    IO.inspect("ssp")

    case Todos.update_todo(socket.assigns.todo, todo_params) do
      {:ok, todo} ->
        notify_parent({:saved, todo})

        Appsignal.Logger.info(
          "handle_event",
          "Saving edited todo #{todo.id} by #{socket.assigns.creator_id}"
        )

        {:noreply,
         socket
         |> put_flash(:info, "Todo updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        Appsignal.Logger.error(
          "handle_event",
          "Failed to Save edited todo #{todo_params.id} by #{socket.assigns.creator_id}"
        )

        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_todo(socket, :new, todo_params) do
    case Todos.create_todo(todo_params) do
      {:ok, todo} ->
        Appsignal.Logger.info(
          "handle_event",
          "Saving new todo #{todo.id} by #{socket.assigns.creator_id}"
        )

        Permissions.create_permission(%{
          "todo_id" => todo.id,
          "user_id" => socket.assigns.current_user.id,
          "role_id" => Roles.get_role_by_name!("Creator").id
        })

        Appsignal.Logger.info(
          "handle_event",
          "Creating new Creator permission #{todo.id} for #{socket.assigns.creator_id}"
        )

        notify_parent({:saved, todo})
        IO.inspect(socket)

        {:noreply,
         socket
         |> put_flash(:info, "Todo created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        Appsignal.Logger.error(
          "handle_event",
          "Failed to Save new todo #{todo_params.id} by #{socket.assigns.creator_id}"
        )

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
