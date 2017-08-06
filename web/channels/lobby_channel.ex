defmodule AvalonBackend.LobbyChannel do
  use AvalonBackend.Web, :channel
  alias AvalonBackend.RoomModel
  alias AvalonBackend.UserModel

  def join("lobby", _payload, socket) do
    user = Map.get(socket.assigns, :user)
    case UserModel.user_log_in(user) do
      {:ok, users} -> 
        send self(), {:after_join, users}
        {:ok, %{ id: user.id }, socket}
      {:error, reason} ->
        {:error, reason}
      _ ->
        {:error, "Unexpected error."}
    end
  end

  def terminate(_reason, socket) do
    user = Map.get(socket.assigns, :user)
    case UserModel.user_log_out(user) do
      {:ok, users} -> 
        lobby_update_users(users)
        :ok
      {:error, reason} ->
        IO.puts "error"
        {:error, reason}
      _ ->
        {:error, "Unexpected error."}
    end
  end

  def handle_info({:after_join, users}, socket) do
    lobby_update_users(users)
    {:noreply, socket}
  end

  def handle_in("createRoom", %{ }, socket) do

    user = Map.get(socket.assigns, :user)
    
    case RoomModel.create(user) do
      {:ok, rooms, room, number } ->
        users = UserModel.change_user_state(user, %{ :room => number})
        AvalonBackend.Endpoint.broadcast "lobby", "message", %{ message: room }
        lobby_update_all(%{ :users => users, :rooms => rooms })
        {:noreply, socket}
      {:error, reason} ->
        {:reply, {:error, %{ :reason => reason }}, socket}
      _ ->
        {:reply, {:error, %{ :reason => "Unexpected error" }}, socket}
    end

  end
  
  def handle_in("joinRoom", %{ "number" => number }, socket) do
    user = socket.assigns.user
    
    users = UserModel.change_user_state(user, %{ :room => number})
    { status, rooms, room, number } = RoomModel.join(number, user)
    
    lobby_update_all(%{ :users => users, :rooms => rooms })

    # AvalonBackend.Endpoint.broadcast "room:" <> number , "join", %{ user: user }
    {:noreply, socket}
  end

  defp lobby_update_all(%{:users => users, :rooms => rooms}) do
    lobby_update_rooms(rooms)
    lobby_update_users(users)
  end

  defp lobby_update_rooms(rooms) do
    AvalonBackend.Endpoint.broadcast "lobby", "lobby_update_rooms", %{ rooms: get_rooms(rooms)}
  end

  defp lobby_update_users(users) do
    AvalonBackend.Endpoint.broadcast "lobby", "lobby_update_users", %{ users: get_users(users) }
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