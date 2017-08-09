defmodule AvalonBackend.LobbyChannel do
  use AvalonBackend.Web, :channel
  alias AvalonBackend.RoomModel
  alias AvalonBackend.UserModel

  def join("lobby", _payload, socket) do
    id = socket.id
    users = UserModel.user_log_in(id) 
    send self(), {:after_join, users}
    {:ok, %{ id: id }, socket}
  end

  def terminate(_reason, socket) do
    id = socket.id
    users = UserModel.user_log_out(id) 
    lobby_update_users(users)
    :ok
  end

  def handle_info({:after_join, users}, socket) do
    lobby_update_users(users)
    {:noreply, socket}
  end

  def handle_in("createRoom", %{ }, socket) do
    id = socket.id
    {rooms, room, number} = RoomModel.create(id)
    users = UserModel.update(id, %{:number => number})
    # AvalonBackend.Endpoint.broadcast "lobby", "message", %{ message: room }
    lobby_update_all(%{ :users => users, :rooms => rooms })
    {:reply, {:ok, %{:number => number}}, socket}
  end
  
  def handle_in("joinRoom", %{ "number" => number }, socket) do

    id = socket.id
    
    case RoomModel.join(number, id) do
      {:ok, rooms, room, number} -> 
        users = UserModel.update(id, %{:number => number})
        lobby_update_all(%{ :users => users, :rooms => rooms })
        {:reply, {:ok, %{:number => number}}, socket}
      {:full} ->
        {:reply, :full, socket}
      {:exist} ->
        {:reply, :exist, socket}
      {:login_limit} ->
        {:reply, :login_limit, socket}
    end

  end

  def handle_in("watchRoom", %{ "number" => number }, socket) do
    id = socket.id
    case RoomModel.watch(number, id) do
      {:ok, rooms, room, number} -> 
        users = UserModel.update(id, %{:number => number, :state => :watch})
        lobby_update_all(%{ :users => users, :rooms => rooms })
        {:reply, {:ok, %{:number => number}}, socket}
      {:exist} ->
        {:reply, :exist, socket}
      {:watch_limit} ->
        {:reply, :watch_limit, socket}
      {:login_limit} ->
        {:reply, :login_limit, socket}
    end
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