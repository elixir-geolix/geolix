defmodule Geolix.TestHelpers.DatabaseSupervisor do
  @moduledoc false

  @doc """
  Restarts the database supervisor.
  """
  @spec restart() :: :ok
  def restart do
    Supervisor.terminate_child(Geolix.Supervisor, Geolix.Database.Supervisor)
    Supervisor.restart_child(Geolix.Supervisor, Geolix.Database.Supervisor)

    :timer.sleep(50)
    :ok
  end
end
