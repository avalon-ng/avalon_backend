defmodule AvalonBackend.UserModel do
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def user_log_in(nil), do: {:error, "User is empty."}
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
    {status, user} = update(user, :state, state)
    {status, users} = update(users, user.id, user)
    {:reply, users, users}
  end

  def handle_call({:user_logged_in, user}, _from, users) do

    id = Map.get(user, :id)

    case add(users, id, user) do
      {:ok, users} ->
        {:reply, {:ok, users}, users}
      {:error, reason} ->
        {:reply, {:error, reason}, users}
      _ -> 
        {:reply, {:error, "Unexpected Error"}, users}
    end

  end

  def handle_call({:user_logged_out, user}, _from, users) do
    {status, users} = remove(users, user.id)
    {:reply, {status, users}, users}
  end

  defp add(state, nil, value), do: {:error, "Key is nil."}
  defp add(state, key, value) do
    case Map.get(state, key) do
      nil -> 
        state = Map.put(state, key, value)
        {:ok, state}
      _ -> 
        {:error, "Value exist."}
    end
  end

  defp update(state, key, value) do
    case Map.get(state,key) do
      nil -> 
        {:error, "non exist"}
      _ -> 
        state = Map.put(state, key, value)
        {:ok, state}
    end
  end

  defp remove(state, key) do
    state = Map.delete(state, key)
    {:ok, state}
  end

end