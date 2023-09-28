defmodule Game.App do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    children = [
      %{
        id: Game.CellSupervisor,
        start: {Game.CellSupervisor, :start_link, [:ok]},
        type: :supervisor
      },
      %{
        id: Game.Universe,
        start: {Game.Universe, :start_link, []}
      },
      %{
        id: :cells,
        start: {Registry, :start_link, [:unique, :cells]}
      },
      %{
        id: :starts,
        start: {Game.LocationRegistry, :start_link, [:starts]}
      },
      %{
        id: :kills,
        start: {Game.LocationRegistry, :start_link, [:kills]}
      },
      %{
        id: Game.Draw,
        start: {Game.Draw, :start_link, [:ok]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
