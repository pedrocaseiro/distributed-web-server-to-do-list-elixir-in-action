defmodule Todo.Server do
	use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

	def start_link(name) do
    IO.puts('starting to-do server')
		GenServer.start_link(Todo.Server, name, name: via_tuple(name))
	end

	def add_entry(todo_server, new_entry) do
		GenServer.cast(todo_server, {:add_entry, new_entry})
	end

	def entries(todo_server, date) do
		GenServer.call(todo_server, {:entries, date})
	end

	@impl GenServer
	def init(name) do
    {
      :ok,
      {name, Todo.Database.get(name) || Todo.List.new()},
      @expiry_idle_timeout
    }
	end

	@impl GenServer
	def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
		new_state = Todo.List.add_entry(todo_list, new_entry)
		Todo.Database.store(name, new_state)
		{:noreply, {name, new_state}, @expiry_idle_timeout}
	end

	@impl GenServer
	def handle_call({:entries, date}, _, {name, todo_list}) do
		{
			:reply,
			Todo.List.entries(todo_list, date),
      {name, todo_list},
      @expiry_idle_timeout
		}
	end

  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end

  def handle_info(unknown_message, state) do
    super(unknown_message, state)
    {:noreply, state, @expiry_idle_timeout}
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
