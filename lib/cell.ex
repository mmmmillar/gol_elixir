defmodule Game.Cell do
  use GenServer, restart: :transient

  @neighbour_offsets [
    {-1, -1},
    {0, -1},
    {1, -1},
    {-1, 0},
    {1, 0},
    {-1, 1},
    {0, 1},
    {1, 1}
  ]

  def start_link([location]) do
    name = {:via, Registry, {:cells, location}}
    GenServer.start_link(__MODULE__, location, name: name)
  end

  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  def is_alive(location) do
    Registry.lookup(:cells, location) != []
  end

  def num_neighbours({x, y}) do
    @neighbour_offsets
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.map(fn location -> is_alive(location) end)
    |> Enum.filter(fn alive -> alive end)
    |> length()
  end

  @impl true
  def init(location) do
    {:ok, location}
  end

  @impl true
  def handle_call(:tick, _from, location) do
    result = process_community(location)
    {:reply, result, location}
  end

  defp process_community({x, y}) do
    [
      {x, y}
      | @neighbour_offsets
        |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    ]
    |> Enum.each(fn location -> process_cell(location) end)
  end

  # any live cell with two or three live neighbours survives.
  # any dead cell with three live neighbours becomes a live cell.
  # all other live cells die in the next generation. Similarly, all other dead cells stay dead.
  defp process_cell({x, y}) do
    location = {x, y}

    cond do
      x < 0 ->
        :ok

      y < 0 ->
        :ok

      Game.LocationRegistry.member?(:starts, location) ->
        :ok

      Game.LocationRegistry.member?(:kills, location) ->
        :ok

      true ->
        case {is_alive(location), num_neighbours(location)} do
          {true, 2} ->
            :ok

          {true, 3} ->
            :ok

          {false, 3} ->
            Game.LocationRegistry.add(:starts, location)
            :ok

          {false, _} ->
            :ok

          _ ->
            Game.LocationRegistry.add(:kills, location)
            :ok
        end
    end
  end
end
