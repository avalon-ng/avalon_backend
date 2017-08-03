defmodule AvalonBackend.LobbyChannel do
  use AvalonBackend.Web, :channel
  alias AvalonBackend.RoomModel
  alias AvalonBackend.UserModel

  def join("game:lobby", _payload, socket) do
    user = socket.assigns.user
    users = UserModel.user_joined("game:lobby", user)["game:lobby"]
    send self(), {:after_join, users}
    {:ok, %{ id: user.id }, socket}
  end

  def terminate(_reason, socket) do
    user_id = socket.assigns.user.id
    users = UserModel.user_left("game:lobby", user_id)["game:lobby"]
    lobby_update(socket, users)
    :ok
  end

	def handle_in("createRoom", %{ }, socket) do
    user = socket.assigns.user
    room = RoomModel.create(user)
		AvalonBackend.Endpoint.broadcast "game:lobby", "message", %{ message: room }
		{:noreply, socket}
	end

  def handle_info({:after_join, users}, socket) do
    lobby_update(socket, users)
    {:noreply, socket}
  end

  defp lobby_update(socket, users) do
    broadcast! socket, "lobby_update", %{ users: get_usernames(users) }
  end

  defp get_usernames(nil), do: []
  defp get_usernames(users) do
    Enum.map users, &(&1.username)
  end
end