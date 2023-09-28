defmodule Game.Draw do
  alias Game.Universe
  use Task

  @width 10
  @depth 10

  def start_link(_) do
    Task.start_link(__MODULE__, :process, [])
    Game.Universe.setup()
    Universe.living_cells()
    process()
  end

  def square_value(x, y, cells) do
    cond do
      Enum.member?(cells, {x, y}) ->
        "o"

      true ->
        "."
    end
  end

  def draw_grid(cells, grid \\ "", x \\ 0, y \\ 0) do
    square = square_value(x, y, cells)

    cond do
      {x, y} == {@width, @depth} ->
        grid <> square

      x == @width ->
        draw_grid(cells, grid <> square <> "\n", 0, y + 1)

      x < @width ->
        draw_grid(cells, grid <> square, x + 1, y)
    end
  end

  def process() do
    receive do
    after
      50 ->
        grid = draw_grid(Universe.living_cells())
        IO.write("\r#{grid}")
        IO.write(IO.ANSI.cursor_up(@depth))
        Game.Universe.tick()
        process()
    end
  end
end
