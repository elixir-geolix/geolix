defmodule Geolix.Database.LoaderErrorTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Geolix.Adapter.MMDB2
  alias Geolix.Database.Supervisor, as: DatabaseSupervisor


  setup do
    databases = Application.get_env(:geolix, :databases)

    on_exit fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
    end
  end

  defp restart_supervisor() do
    true =
      DatabaseSupervisor
      |> Process.whereis()
      |> Process.exit(:kill)

    :timer.sleep(250)

    :ok
  end


  test "(re-) loading databases at startup logs errors" do
    id = :initially_broken
    db = %{
      id:      id,
      adapter: MMDB2,
      source:  Path.join([ __DIR__, "does-not-exist" ])
    }

    assert capture_log(fn ->
      :ok = Application.put_env(:geolix, :databases, [ db ])
      :ok = restart_supervisor()
      :ok = Geolix.reload_databases()

      # ensure GenServer.cast/1 was processed
      :timer.sleep(100)
    end) =~ "does not exist"
  end
end
