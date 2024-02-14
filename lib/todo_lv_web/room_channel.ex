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

  def handle_in("new_msg", %{"body" => body}, socket) do
    IO.inspect(body)
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end

  def handle_in("new_msg2", %{"body" => body}, socket) do
    IO.inspect(body)
    broadcast!(socket, "new_msg2", %{body: body})
    {:noreply, socket}
  end
end
