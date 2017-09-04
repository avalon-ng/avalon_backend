defmodule AvalonBackend.LobbyChannelTest do
  use AvalonBackend.ChannelCase
  alias AvalonBackend.UserSocket
  alias AvalonBackend.LobbyChannel
  alias AvalonBackend.UserModel
  alias AvalonBackend.RoomModel

  def connectLobby() do
    {:ok, socket} = connect(UserSocket, %{}) 
    {:ok, _, socket} = subscribe_and_join(socket, "lobby")
    socket
  end

  test "user connect and update user model" do
    socket = connectLobby()
    assert socket.id !== "" && socket.id !== nil && UserModel.get(socket.id) !== nil
  end

  test "create room" do
    socket = connectLobby()
    ref = push socket, "createRoom", %{}

    assert_reply ref, :ok
    user = UserModel.get(socket.id)

    assert user.number !== :lobby
    number = user.number

    assert RoomModel.get(number) !== nil
  end
  
end