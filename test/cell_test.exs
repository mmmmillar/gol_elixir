defmodule Game.CellTest do
  use ExUnit.Case, async: false

  setup do
    start_supervised({Registry, keys: :unique, name: :cells})
    start_supervised({Game.LocationRegistry, :starts}, id: :starts)
    start_supervised({Game.LocationRegistry, :kills}, id: :kills)
    %{}
  end

  test "starts a cell" do
    Game.Cell.start_link([{5, 5}])
    assert Registry.lookup(:cells, {5, 5}) != []
  end

  test "is_alive" do
    Game.Cell.start_link([{5, 5}])
    assert Game.Cell.is_alive({5, 5}) == true
    assert Game.Cell.is_alive({4, 4}) == false
  end

  test "num_neighbours when fully surrounded" do
    Game.Cell.start_link([{4, 4}])
    Game.Cell.start_link([{4, 5}])
    Game.Cell.start_link([{4, 6}])
    Game.Cell.start_link([{5, 4}])
    Game.Cell.start_link([{5, 5}])
    Game.Cell.start_link([{5, 6}])
    Game.Cell.start_link([{6, 4}])
    Game.Cell.start_link([{6, 5}])
    Game.Cell.start_link([{6, 6}])

    assert Game.Cell.num_neighbours({5, 5}) == 8
  end

  test "num_neighbours when 2 neighbours" do
    Game.Cell.start_link([{4, 6}])
    Game.Cell.start_link([{5, 4}])
    Game.Cell.start_link([{5, 5}])

    assert Game.Cell.num_neighbours({5, 5}) == 2
  end

  test "num_neighbours when 0 neighbours" do
    Game.Cell.start_link([{3, 3}])
    Game.Cell.start_link([{1, 1}])
    Game.Cell.start_link([{5, 5}])

    assert Game.Cell.num_neighbours({5, 5}) == 0
  end

  test ":tick when 2 neighbours cell will survive" do
    Game.Cell.start_link([{4, 6}])
    Game.Cell.start_link([{5, 4}])
    {:ok, pid} = Game.Cell.start_link([{5, 5}])

    Game.Cell.tick(pid)

    assert Game.LocationRegistry.member?(:starts, {5, 5}) == false
    assert Game.LocationRegistry.member?(:kills, {5, 5}) == false
  end

  test ":tick when 3 neighbours cell will survive" do
    Game.Cell.start_link([{4, 6}])
    Game.Cell.start_link([{5, 4}])
    Game.Cell.start_link([{6, 4}])
    {:ok, pid} = Game.Cell.start_link([{5, 5}])

    Game.Cell.tick(pid)

    assert Game.LocationRegistry.member?(:starts, {5, 5}) == false
    assert Game.LocationRegistry.member?(:kills, {5, 5}) == false
  end

  test ":tick when 4 neighbours cell will die" do
    Game.Cell.start_link([{4, 6}])
    Game.Cell.start_link([{5, 4}])
    Game.Cell.start_link([{6, 4}])
    Game.Cell.start_link([{6, 6}])
    {:ok, pid} = Game.Cell.start_link([{5, 5}])

    Game.Cell.tick(pid)

    assert Game.LocationRegistry.member?(:kills, {5, 5})
  end

  test ":tick when 1 neighbour cell will die" do
    Game.Cell.start_link([{4, 6}])
    {:ok, pid} = Game.Cell.start_link([{5, 5}])

    Game.Cell.tick(pid)

    assert Game.LocationRegistry.member?(:kills, {5, 5})
  end

  test ":tick when dead and 3 neighbours cell will start" do
    Game.Cell.start_link([{4, 6}])
    Game.Cell.start_link([{6, 4}])
    {:ok, pid} = Game.Cell.start_link([{5, 4}])

    Game.Cell.tick(pid)

    assert Game.LocationRegistry.member?(:starts, {5, 5})
  end
end
