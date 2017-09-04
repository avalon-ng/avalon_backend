defmodule AvalonBackend.GameChannel do
  use AvalonBackend.Web, :channel
  alias AvalonBackend.RoomModel
  alias AvalonBackend.GameModel
  alias AvalonBackend.UserModel

  def join("game:" <> number, _payload, socket) do
    id = socket.id
    user = UserModel.get(id)
    AvalonBackend.Endpoint.broadcast "game:" <> number, "joined", %{ name: user.name }
    { :ok, socket }
  end

  def terminate(_reason, socket) do
    id = socket.id
    user = UserModel.get(id)
    if user !== nil do
      number = user.number
      AvalonBackend.Endpoint.broadcast "game:" <> number, "leaveGame", %{ name: user.name }
    end
    :ok
  end

end