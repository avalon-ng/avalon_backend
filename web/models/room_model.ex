defmodule AvalonBackend.RoomModel do
  use GenServer

  def start_link(initial_state) do
   	GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

	def create(user) do
  	GenServer.call(__MODULE__, {:room_created, user})
	end

  def handle_call({:room_created, user}, _from, state) do
    number = Integer.to_string Enum.random(0..1000)
    newState = Map.put(state, "room:" <> number, [user])
    {:reply, newState, newState}
  end

end