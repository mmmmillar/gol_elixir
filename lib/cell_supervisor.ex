defmodule Game.CellSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_cell(x, y) do
    {:ok, child} = DynamicSupervisor.start_child(__MODULE__, {Game.Cell, [{x, y}]})
    {:ok, child}
  end

  def kill_cell(x, y) do
    [{pid, _}] = Registry.lookup(:cells, {x, y})
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
