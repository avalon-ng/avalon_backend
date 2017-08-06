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

  def change_user_state(user, :room, number) do
    GenServer.call(__MODULE__, {:user_state_changed, user, number})
  end


  def handle_call({:user_state_changed, user, number}, _from, state) do
    # TODO change user state
    {:reply, state, state}
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

  def handle_call({:users_in_channel, channel}, _from, state) do
    {:reply, Map.get(state, channel), state}
  end

  defp update(state, key, value) do
    state = Map.put(state, key, value)
  end

  defp remove(state, key) do
    state = Map.delete(state, key)
  end

end