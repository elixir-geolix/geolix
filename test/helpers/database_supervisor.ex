defmodule Geolix.TestHelpers.DatabaseSupervisor do
  @moduledoc false

  @doc """
  Restarts the database supervisor.
  """
  @spec restart() :: :ok
  def restart() do
    true =
      Geolix.Database.Supervisor
      |> Process.whereis()
      |> Process.exit(:kill)

    :ok = :timer.sleep(100)
    _   = Application.ensure_all_started(:geolix)
    :ok = Geolix.reload_databases()
    :ok = :timer.sleep(100)
    :ok
  end
end
