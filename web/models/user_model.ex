defmodule AvalonBackend.UserModel do
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def update(user, map) do
    GenServer.call(__MODULE__, {:update, user, map})
  end

  def user_log_in(user) do
    GenServer.call(__MODULE__, {:user_logged_in, user})
  end

  def user_log_out(user) do
    GenServer.call(__MODULE__, {:user_logged_out, user})
  end

  def change_user_state(user, state) do
    GenServer.call(__MODULE__, {:user_state_changed, user, state})
  end

  def handle_call({:user_state_changed, user, state}, _from, users) do
    state = Map.merge(user, state)
    user = update(user, :state, state)
    users = update(users, user.id, user)
    {:reply, users, users}
  end

  def handle_call({:user_logged_in, user}, _from, users) do
    id = user.id
    users = update(users, id, user)
    {:reply, users, users}
  end

  def handle_call({:user_logged_out, user}, _from, users) do
    id = user.id
    users = remove(users, id)
    {:reply, users, users}
  end

  def handle_call({:update, user, map}, _from, users) do
    id = user.id
    user = Map.merge(user, map)
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