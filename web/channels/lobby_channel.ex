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
    lobby_update_users(socket, users)
    :ok
  end

  def handle_info({:after_join, users}, socket) do
    lobby_update_users(socket, users)
    {:noreply, socket}
  end

  def handle_in("createRoom", %{ }, socket) do
    user = socket.assigns.user

    { rooms, room, number }  = RoomModel.create(user)
    users = UserModel.change_user_state(user, :room, number )

    AvalonBackend.Endpoint.broadcast "game:lobby", "message", %{ message: room }

    lobby_update_all(socket, %{ :users => users, :rooms => rooms })
    {:noreply, socket}
  end
  
  def handle_in("joinRoom", %{ "number" => number }, socket) do
    user = socket.assigns.user
    
    { rooms, room, number } = RoomModel.join(number, user)
    users = UserModel.change_user_state(user, :room, number )
    
    lobby_update_all(socket, %{ :users => users, :rooms => rooms })

    # AvalonBackend.Endpoint.broadcast "room:" <> number , "join", %{ user: user }
    {:noreply, socket}
  end

  defp lobby_update_all(socket, args) do
    users = args[:users]
    rooms = args[:rooms]
    lobby_update_rooms(socket, rooms)
    lobby_update_users(socket, users)
  end

  defp lobby_update_rooms(socket, rooms) do
    broadcast! socket, "lobby_update_rooms", %{ rooms: get_rooms(rooms) }
  end

  defp lobby_update_users(socket, users) do
    broadcast! socket, "lobby_update_users", %{ users: get_users(users) }
  end

  defp get_rooms(nil), do: []
  defp get_rooms(rooms) do
    rooms
  end

  defp get_users(nil), do: []
  defp get_users(users) do
    users
  end
end