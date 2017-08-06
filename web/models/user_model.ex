defmodule AvalonBackend.UserModel do
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def user_log_in(user) do
    GenServer.call(__MODULE__, {:user_logged_in, user})
  end

  def users_in_channel(channel) do
    GenServer.call(__MODULE__, {:users_in_channel, channel})
  end

  def user_log_out(user) do
    GenServer.call(__MODULE__, {:user_logged_out, user})
  end

  def change_user_state(user, state) do
    GenServer.call(__MODULE__, {:user_state_changed, user, state})
  end

  def handle_call({:user_state_changed, user, state}, _from, users) do
    {status, user} = update(user, :state, state)
    {status, users} = update(users, user.id, user)
    {:reply, users, users}
  end

  def handle_call({:user_logged_in, user}, _from, users) do
    {status, users} = update(users, user.id, user)
    {:reply, users, users}
  end

  def handle_call({:user_logged_out, user}, _from, users) do
    {status, users} = remove(users, user.id)
    {:reply, users, users}
  end

  def handle_call({:users_in_channel, channel}, _from, state) do
    {:reply, Map.get(state, channel), state}
  end

  defp update(state, key, value) do
    state = Map.put(state, key, value)
    {:ok, state}
  end

  defp remove(state, key) do
    state = Map.delete(state, key)
    {:ok, state}
  end

end