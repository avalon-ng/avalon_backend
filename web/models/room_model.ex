defmodule AvalonBackend.RoomModel do
  use GenServer
  alias AvalonBackend.UserModel

  def start_link(initial_state) do
     GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def create(id, args) do
    GenServer.call(__MODULE__, {:room_created, id, args})
  end

  def create(id) do
    GenServer.call(__MODULE__, {:room_created, id, %{}})
  end
  
  def join(number, id) do
    GenServer.call(__MODULE__, {:user_joined, number, id})
  end

  def watch(number, id) do
    GenServer.call(__MODULE__, {:user_watched, number, id})
  end

  def get(number) do
    GenServer.call(__MODULE__, {:get, number})
  end

  def leave_room(number, id) do
    GenServer.call(__MODULE__, {:user_left, number, id})
  end

  def delete_room(number) do
    GenServer.call(__MODULE__, {:delete_room, number})
  end

  def handle_call({:delete_room, number}, _from, rooms) do
    room = get(rooms, number)
    if Enum.count(room.users) === 0 && Enum.count(room.watchers) === 0 do
      rooms = delete(rooms, number)
    end
    {:reply, rooms, rooms}
  end

  def handle_call({:get, number}, _from, rooms) do
    {:reply, get(rooms, number), rooms}
  end

  def handle_call({:user_left, number, id}, _from, rooms) do
    room = get(rooms, number)
    case room do
      nil -> 
        {:reply, rooms, rooms}
      _ -> 
        %{:watchers => watchers, :users => users} = room
        watchers = watchers -- [id]
        users = users -- [id]
        room = update(room, :users, users)
        room = update(room, :watchers, watchers)
        rooms = update(rooms, number, room)
        {:reply, rooms, rooms}
    end
  end

  def handle_call({:room_created, id, args}, _from, rooms) do
    # todo unique
    user = UserModel.get(id)
    number = Integer.to_string Enum.random(0..1000)
    room = create_room(number)
    room = set_room_config(room, args)
    room = add_user(room, user)
    rooms = update(rooms, number, room)
    {:reply, {rooms, room, number}, rooms}
  end

  def handle_call({:user_joined, number, id}, _from, rooms) do
    user = UserModel.get(id)
    room = rooms[number]
    cond do
      Map.get(rooms, number) === nil -> 
        {:reply, {:error}, rooms} 
      room.user_limit <= length(room.users) ->
        {:reply, {:full}, rooms}
      user.number !== :lobby || user.state !== :idle ->
        {:reply, {:exist}, rooms}
      user.login !== room.login_limit ->
        {:reply, {:login_limit}, rooms}
      true -> 
        room = add_user(rooms[number], user)
        rooms = update(rooms, number, room)
        {:reply, {:ok, rooms, room, number}, rooms}
    end
  end

  def handle_call({:user_watched, number, id}, _from, rooms) do
    user = UserModel.get(id)
    room = rooms[number]
    cond do
      Map.get(rooms, number) === nil -> 
        {:reply, {:error}, rooms} 
      room.watch_limit ->
        {:reply, {:watch_limit}, rooms}
      user.number !== :lobby || user.state !== :idle ->
        {:reply, {:exist}, rooms}
      user.login !== room.login_limit ->
        {:reply, {:login_limit}, rooms}
      true -> 
        room = add_watcher(rooms[number], user)
        rooms = update(rooms, number, room)
        {:reply, {:ok, rooms, room, number}, rooms}
    end
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

  defp set_room_config(room, args) do
    room = Map.merge(room, args)
  end

  defp create_room(number) do
    config = %{
      :goddess => false,
      :roles => []
    }
    room = %{ 
      :creater => nil,
      :state => :idle,
      :password => nil,
      :users => [], 
      :watchers => [],
      :number => number,
      :watch_limit => false, 
      :user_limit => 10, 
      :login_limit => false,
      :config => config
    }
  end

  defp add_user(room, user) do
    users = room.users ++ [user.id]
    room = update(room, :users, users) 
  end

  defp add_watcher(room, watcher) do
    watchers = room.watchers ++ [watcher.id]
    room = update(room, :watchers, watchers) 
  end

end