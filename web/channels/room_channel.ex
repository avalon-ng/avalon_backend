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
            %{ "status" => status } = body
            if status === "fail" do
              {:reply, {:invalid, body}, socket}
            else
              {:reply, {:ok, body}, socket}
            end
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
    roles = [%{ role: :Test1, align: 1 }, %{ role: :Test2, align: -1 }, %{ role: :Test3, align: 1 }, %{ role: :Test4, align: -1 }, %{ role: :Test5, align: 1 }]
    roles = Enum.shuffle roles 
    users 
      |> Enum.shuffle
      |> Enum.with_index
      |> Enum.map(fn({user, index}) -> 
        role = Enum.at(roles, index)
        %{ id: user, align: role.align, role: role.role } 
      end) 
  end

end