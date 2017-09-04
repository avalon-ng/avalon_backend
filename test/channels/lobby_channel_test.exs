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

  def joinRoom(socket, number) do
    ref = push socket, "joinRoom", %{number: number}
    assert_reply ref, :ok, %{number: number}
    number
  end

  test "user connect" do
    socket = connectLobby()
    assert socket.id !== "" && socket.id !== nil 
    assert UserModel.get(socket.id) !== nil
  end

  test "create room" do
    socket = connectLobby()
    number = createRoom(socket)

    assert UserModel.get(socket.id).number === number 
    assert RoomModel.get(number) !== nil
    
    # create room again without exit
    ref = push socket, "createRoom", %{}
    assert_reply ref, :error
  end

  test "join room" do
    creator = connectLobby()
    number = createRoom(creator)

    player2 = connectLobby()
    joinRoom(player2, number)

    room = RoomModel.get(number)
    users = room.users
    assert length(users) === 2
    assert Enum.at(users, 0) !== Enum.at(users, 1)
  end
  
end