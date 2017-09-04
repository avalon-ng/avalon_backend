defmodule AvalonBackend.LobbyChannelTest do
  use AvalonBackend.ChannelCase
  alias AvalonBackend.UserSocket
  alias AvalonBackend.LobbyChannel

  test "user receives the current list of users online" do
    {:ok, socket} = connect(UserSocket, %{}) 
    {:ok, _, socket} = subscribe_and_join(socket, "lobby")
  end
end