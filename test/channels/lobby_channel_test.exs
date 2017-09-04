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

  def createRoom(socket) do
    ref = push socket, "createRoom", %{}
    assert_reply ref, :ok, %{number: number}
    number
  end

  test "user connect and update user model" do
    socket = connectLobby()
    assert socket.id !== "" && socket.id !== nil && UserModel.get(socket.id) !== nil
  end

  test "create room" do
    socket = connectLobby()
    number = createRoom(socket)

    assert UserModel.get(socket.id).number === number && RoomModel.get(number) !== nil
  end

  test "join room" do
    
  end
  
end