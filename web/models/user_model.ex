defmodule AvalonBackend.UserModel do
  use GenServer
  alias AvalonBackend.RoomModel

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def update(id, map) do
    GenServer.call(__MODULE__, {:update, id, map})
  end

  def user_log_in(id) do
    GenServer.call(__MODULE__, {:user_logged_in, id})
  end

  def user_log_out(id) do
    GenServer.call(__MODULE__, {:user_logged_out, id})
  end

  def change_user_state(id, state) do
    GenServer.call(__MODULE__, {:user_state_changed, id, state})
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  def handle_call({:get, id}, _from, users) do
    {:reply, users[id], users}
  end

  def handle_call({:user_state_changed, id, state}, _from, users) do
    user = users[id]
    state = Map.merge(user, state)
    user = update(user, :state, state)
    users = update(users, user.id, user)
    {:reply, users, users}
  end

  def handle_call({:user_logged_in, id}, _from, users) do
    user = %{ 
      :id => id, 
      :username => id, 
      :log_in_time => DateTime.utc_now(), 
      :state => :idle, 
      :number => :lobby,
      :login => false 
    }
    users = update(users, id, user)
    {:reply, users, users}
  end

  def handle_call({:user_logged_out, id}, _from, users) do
    users = remove(users, id)
    {:reply, users, users}
  end

  def handle_call({:update, id, map}, _from, users) do
    user = Map.merge(users[id], map)
    users = update(users, id, user)
    {:reply, users, users}
  end

  defp update(state, key, value) do
    Map.put(state, key, value)
  end

  defp remove(state, key) do
    Map.delete(state, key)
  end

end