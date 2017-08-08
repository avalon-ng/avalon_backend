defmodule AvalonBackend.RoomModel do
  use GenServer

  def start_link(initial_state) do
     GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def create(user, args) do
    GenServer.call(__MODULE__, {:room_created, user, args})
  end

  def create(user) do
    GenServer.call(__MODULE__, {:room_created, user, %{}})
  end
  
  def join(number, user) do
    GenServer.call(__MODULE__, {:user_joined, number, user})
  end

  def handle_call({:room_created, user, args}, _from, rooms) do
    # todo unique
    number = Integer.to_string Enum.random(0..1000)
    room = create_room(number)
    room = set_room_config(room, args)
    room = add_user(room, user)
    rooms = update(rooms, number, room)
    {:reply, {rooms, room, number}, rooms}
  end

  def handle_call({:user_joined, number, user}, _from, rooms) do
    room = rooms[number]
    cond do
      room.user_limit <= length(room.users) ->
        {:reply, {:full}, rooms}
      true -> 
        room = add_user(rooms[number], user)
        rooms = update(rooms, number, room)
        {:reply, {:ok, rooms, room, number}, rooms}
    end
  end

  defp update(state, key, value) do
    state = Map.put(state, key, value)
  end

  defp set_room_config(room, args) do
    room = Map.merge(room, args)
  end

  defp create_room(number) do
    room = %{ 
      :creater => nil,
      :state => :idle,
      :password => nil,
      :users => [], 
      :watchers => [],
      :number => number,
      :watch_limit => true, 
      :user_limit => 10, 
      :login_limit => false,
      :config => %{
        :goddess => false,
        :roles => []
      }
    }
  end

  defp add_user(room, user) do
    users = room.users ++ [user.id]
    room = update(room, :users, users) 
  end

end