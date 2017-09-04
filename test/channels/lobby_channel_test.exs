defmodule AvalonBackend.LobbyChannelTest do
  use AvalonBackend.ChannelCase
  alias AvalonBackend.UserSocket
  alias AvalonBackend.LobbyChannel
  alias AvalonBackend.UserModel

  def connectLobby() do
    {:ok, socket} = connect(UserSocket, %{}) 
    {:ok, _, socket} = subscribe_and_join(socket, "lobby")
    socket
  end

  test "user connect and update user model" do
    socket = connectLobby()
    assert socket.id !== "" && socket.id !== nil && IO.inspect UserModel.get(socket.id) !== nil
  end
  
end