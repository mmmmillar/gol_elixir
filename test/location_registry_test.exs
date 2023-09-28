defmodule Game.LocationRegistryTest do
  use ExUnit.Case, async: false

  test "can add an entry" do
    Game.LocationRegistry.start_link(:starts)
    Game.LocationRegistry.add(:starts, {5, 5})
    assert Game.LocationRegistry.member?(:starts, {5, 5})
  end

  test "can reset the registry" do
    Game.LocationRegistry.start_link(:starts)
    Game.LocationRegistry.add(:starts, {5, 5})
    Game.LocationRegistry.add(:starts, {4, 4})
    Game.LocationRegistry.reset(:starts)
    assert Game.LocationRegistry.values(:starts) == []
  end
end
