defmodule Game.UniverseTest do
  use ExUnit.Case, async: false

  setup do
    start_supervised({Registry, keys: :unique, name: :cells})
    start_supervised({Game.LocationRegistry, :starts}, id: :starts)
    start_supervised({Game.LocationRegistry, :kills}, id: :kills)
    start_supervised(Game.CellSupervisor)
    %{}
  end

  # test "create the universe" do
  #   Game.Universe.start_link()
  #   Game.Universe.setup()
  #   assert length(Supervisor.which_children(Game.CellSupervisor)) == 1
  # end
end
