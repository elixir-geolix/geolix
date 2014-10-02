defmodule Geolix.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], [])
  end

  def init([]) do
    supervise([ worker(Geolix.Server, []) ], strategy: :one_for_one)
  end
end
