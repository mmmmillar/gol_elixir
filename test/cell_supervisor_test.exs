defmodule Game.CellSupervisorTest do
  use ExUnit.Case, async: false

  setup do
    start_supervised({Registry, keys: :unique, name: :cells})
    start_supervised(Game.CellSupervisor)
    %{}
  end

  test "starts a supervised cell" do
    Game.CellSupervisor.start_cell(5, 5)
    assert Registry.lookup(:cells, {5, 5}) != []
  end

  test "kills a supervised cell" do
    Game.CellSupervisor.start_cell(5, 5)
    Game.CellSupervisor.kill_cell(5, 5)
    assert Registry.lookup(:cells, {5, 5}) == []
  end
end
