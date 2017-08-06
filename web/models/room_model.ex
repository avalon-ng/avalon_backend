defmodule AvalonBackend.RoomModel do
  use GenServer

  def start_link(initial_state) do
     GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def create(user) do
    GenServer.call(__MODULE__, {:room_created, user})
  end
  
  def join(number, user) do
    GenServer.call(__MODULE__, {:user_joined, number, user})
  end

  def handle_call({:room_created, user}, _from, rooms) do

    # todo unique
    number = Integer.to_string Enum.random(0..1000)

    {status, room} = create_room(number)
    {status, room} = add_user(room, user)
    {status, rooms} = update(rooms, number, room)

    {:reply, { rooms, room, number }, rooms}
  end


  def handle_call({:user_joined, number, user}, _from, rooms) do

    {status, room} = add_user(rooms[number], user)
    {status, rooms} = update(rooms, number, room)

    {:reply, {rooms, room, number}, rooms}
  end

  defp update(state, key, value) do
    state = Map.put(state, key, value)
    {:ok, state}
  end

  defp create_room(number) do
    room = %{ :users => [], :number => number }
    {:ok, room}
  end

  defp add_user(room, user) do
    users = room.users ++ [user.id]
    {status, room} = update(room, :users, users)
    {:ok, room}
  end

end