defmodule Game.Universe do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def setup() do
    GenServer.call(__MODULE__, :setup)
  end

  def tick() do
    GenServer.call(__MODULE__, :tick)
  end

  def living_cells do
    Registry.select(:cells, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  def spawn(x, y) do
    Game.CellSupervisor.start_cell(x, y)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:setup, _from, state) do
    spawn(1, 0)
    spawn(7, 0)
    spawn(0, 1)
    spawn(2, 1)
    spawn(6, 1)
    spawn(8, 1)
    spawn(0, 2)
    spawn(3, 2)
    spawn(5, 2)
    spawn(8, 2)
    spawn(2, 3)
    spawn(6, 3)
    spawn(2, 4)
    spawn(3, 4)
    spawn(5, 4)
    spawn(6, 4)

    {:reply, state, state}
  end

  @impl true
  def handle_call(:tick, _from, state) do
    # start the new cells
    Game.LocationRegistry.values(:starts)
    |> Enum.each(fn {x, y} -> Game.CellSupervisor.start_cell(x, y) end)

    # kill the old cells
    Game.LocationRegistry.values(:kills)
    |> Enum.each(fn {x, y} -> Game.CellSupervisor.kill_cell(x, y) end)

    # reset start and kill registrys
    Game.LocationRegistry.reset(:starts)
    Game.LocationRegistry.reset(:kills)

    # send out ticks
    Registry.select(:cells, [{{:_, :"$2", :_}, [], [:"$2"]}])
    |> Enum.each(fn pid -> Game.Cell.tick(pid) end)

    {:reply, state, state}
  end
end
