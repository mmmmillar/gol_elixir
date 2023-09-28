defmodule Game.LocationRegistry do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def add(server, value) do
    GenServer.call(server, {:add, value})
  end

  def values(server) do
    GenServer.call(server, :values)
  end

  def member?(server, value) do
    GenServer.call(server, {:member?, value})
  end

  def reset(server) do
    GenServer.call(server, :reset)
  end

  @impl true
  def init(_) do
    {:ok, MapSet.new([])}
  end

  @impl true
  def handle_call({:add, value}, _from, values) do
    updated = MapSet.put(values, value)
    {:reply, updated, updated}
  end

  @impl true
  def handle_call(:values, _from, values) do
    {:reply, MapSet.to_list(values), values}
  end

  @impl true
  def handle_call({:member?, value}, _from, values) do
    {:reply, MapSet.member?(values, value), values}
  end

  @impl true
  def handle_call(:reset, _from, _values) do
    new = MapSet.new([])
    {:reply, new, new}
  end
end
