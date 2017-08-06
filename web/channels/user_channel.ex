defmodule AvalonBackend.UserChannel do
  use AvalonBackend.Web, :channel

  def join("user:" <> _id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("message", %{"id" => id, "message" => message }, socket) do
    AvalonBackend.Endpoint.broadcast "user:" <> id, "message", %{ message: message }
    {:reply, :ok,socket}
  end

end