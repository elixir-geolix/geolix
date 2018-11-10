defmodule Geolix.TestHelpers.DatabaseSupervisor do
  @moduledoc false

  @doc """
  Restarts the database supervisor.
  """
  @spec restart() :: :ok
  def restart() do
    :ok =
      case Process.whereis(Geolix.Database.Supervisor) do
        nil ->
          :ok

        _pid ->
          Supervisor.stop(Geolix.Database.Supervisor, :normal)
          :timer.sleep(50)
      end

    _ = Application.ensure_all_started(:geolix)
    :ok = Geolix.reload_databases()

    :timer.sleep(50)
  end
end
