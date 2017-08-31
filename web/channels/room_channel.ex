defmodule AvalonBackend.RoomChannel do
  use AvalonBackend.Web, :channel
  alias AvalonBackend.RoomModel
  alias AvalonBackend.UserModel


  def join("room:" <> number, _payload, socket) do
    id = socket.id
    user = UserModel.get(id)
    AvalonBackend.Endpoint.broadcast "room:" <> number, "joined", %{ name: user.name }
    { :ok, socket }
  end

  def handle_in("message", %{ "message" => message }, socket) do
    id = socket.id
    user = UserModel.get(id)
    number = user.number
    cond do
      RoomModel.get(number) !== nil ->
        AvalonBackend.Endpoint.broadcast "room:" <> number, "message", %{ name: user.name, message: message }
        {:reply, :ok,socket}
      true ->
        {:reply, :non_exist, socket}
    end
  end

  def handle_in("startGame", %{}, socket) do
    id = socket.id
    user = UserModel.get(id)
    number = user.number
    room = RoomModel.get(number)
    cond do
      room !== nil ->
        fsm_server_url = Application.get_env(:avalon_backend, AvalonBackend.Endpoint)[:fsm_server_url]
        users = init_roles(room.users, room.config.roles)
        result = HTTPoison.post(
          fsm_server_url, 
          Poison.encode!(%{ 
            :type => "initGame",
            :payload => %{ 
              :users => users 
            }
          }), 
          [{"Content-Type", "application/json"}]
        )
        case result do
          {:ok, %HTTPoison.Response{body: body}} ->
            {:ok, body} = Poison.decode(body)
            {:reply, {:ok, body}, socket}
          _ -> 
            {:reply, :error, socket}
        end
      true ->
        {:reply, :non_exist, socket}
    end
  end

  def terminate(_reason, socket) do
    id = socket.id
    user = UserModel.get(id)
    if user !== nil do
      number = user.number
      AvalonBackend.Endpoint.broadcast "room:" <> number, "leaveRoom", %{ name: user.name }
    end
    :ok
  end



  defp init_roles(users, roles) do
    users
  end
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