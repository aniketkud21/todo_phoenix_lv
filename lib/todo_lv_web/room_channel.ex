defmodule TodoLvWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    IO.inspect("hello joined")
    {:ok, socket}
  end

  def join("room:" <> private_room_id, _params, socket) do
    IO.inspect(private_room_id, label: "Private room")
    {:ok, socket}
  end

  # def join("room:" <> "33", _params, socket) do
  #   IO.inspect("joinedddddd")
  #   {:ok, socket}
  # end

  def handle_in("title_input_value", %{"body" => body}, socket) do
    IO.inspect(body)
    broadcast!(socket, "title_input_value", %{body: body})
    {:noreply, socket}
  end

  def handle_in("desc_input_value", %{"body" => body}, socket) do
    IO.inspect(body)
    broadcast!(socket, "desc_input_value", %{body: body})
    {:noreply, socket}
  end

  def handle_in("status_input_value", %{"body" => body}, socket) do
    IO.inspect(body)
    broadcast!(socket, "status_input_value", %{body: body})
    {:noreply, socket}
  end

  def handle_in("category_input_value", %{"body" => body}, socket) do
    IO.inspect(body)
    broadcast!(socket, "category_input_value", %{body: body})
    {:noreply, socket}
  end

  def handle_in("like_input_value", %{"body" => body}, socket) do
    IO.inspect(body)
    broadcast!(socket, "like_input_value", %{body: body})
    {:noreply, socket}
  end
end
