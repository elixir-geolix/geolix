defmodule Geolix.TestHelpers.DatabaseSupervisor do
  @moduledoc false

  @doc """
  Restarts the database supervisor.
  """
  @spec restart() :: :ok
  def restart() do
    :ok = Supervisor.stop(Geolix.Database.Supervisor, :normal)
    :ok = :timer.sleep(50)

    _ = Application.ensure_all_started(:geolix)
    :ok = Geolix.reload_databases()

    :ok = :timer.sleep(50)
    :ok
  end
end
