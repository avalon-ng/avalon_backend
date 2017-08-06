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
    
    {status_create_room, room} = create_room(number)
    {status_add_user, room} = add_user(room, user)
    {status_update, rooms} = 
    if is_map(room) do
      update(rooms, number, room)
    else
      {:error, rooms}
    end

    case {status_create_room, status_add_user, status_update} do
      {:ok, :ok, :ok} ->
        {:reply, {:ok, rooms, room, number}, rooms}
      {:error, _, _} ->
        {:reply, {:error, "Create room error."}, rooms}
      {:ok, :error, _} ->
        {:reply, {:error, "Add user error."}, rooms}
      {:ok, :ok, :error} ->
        {:reply, {:error, "Update rooms error."}, rooms}
      _ ->
        {:reply, {:error, "Unexpected error."}, rooms}
    end

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

  defp add_user(room, user) when is_map(room) and is_map(user) do
    users = room.users ++ [user.id]
    case update(room, :users, users) do
      {:ok, room} -> 
        {:ok, room}
      {:error, reason} ->
        {:error, reason}
      _ ->
        {:error, "Unexpected error."}
    end
  end
  
  defp add_user(_, _) do 
    {:error, "Error arguments."}  
  end

end