defmodule AvalonBackend.RoomChannel do
  use AvalonBackend.Web, :channel
  alias AvalonBackend.RoomModel

  # def join("game:lobby", _payload, socket) do
  #   current_user = socket.assigns.current_user
  #   users = ChannelMonitor.user_joined("game:lobby", current_user)["game:lobby"]
  #   send self(), {:after_join, users}
  #   {:ok, %{ id: current_user.id }, socket}
  # end

  # def terminate(_reason, socket) do
  #   user_id = socket.assigns.current_user.id
  #   users = ChannelMonitor.user_left("game:lobby", user_id)["game:lobby"]
  #   lobby_update(socket, users)
  #   :ok
  # end

  # def handle_info({:after_join, users}, socket) do
  #   lobby_update(socket, users)
  #   {:noreply, socket}
  # end

  # defp lobby_update(socket, users) do
  #   broadcast! socket, "lobby_update", %{ users: get_usernames(users) }
  # end

  # defp get_usernames(nil), do: []
  # defp get_usernames(users) do
  #   Enum.map users, &(&1.username)
  # end
end