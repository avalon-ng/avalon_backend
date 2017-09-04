defmodule AvalonBackend.GameModel do
  use GenServer
  alias AvalonBackend.UserModel

  def start_link(initial_state) do
     GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def create(number, args) do
    GenServer.call(__MODULE__, {:game_created, number, args})
  end

  def handle_call({:game_created, number, args}, _from, games) do
    # user = UserModel.get(id)
    # number = Integer.to_string Enum.random(0..1000)
    # room = create_room(number)
    # room = set_room_config(room, args)
    # room = add_user(room, user)
    # rooms = update(rooms, number, room)
    {:reply, games, games}
  end

  defp get(state, key) do
    Map.get(state, key)
  end

  defp update(state, key, value) do
    state = Map.put(state, key, value)
  end

  defp delete(state, key) do
    state = Map.delete(state, key)
  end

end