defmodule Geolix.Database.LoaderErrorTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Geolix.Adapter.MMDB2
  alias Geolix.Database.Loader
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

    :ok = :timer.sleep(100)
    _   = Application.ensure_all_started(:geolix)
    :ok = Geolix.reload_databases()
    :ok = :timer.sleep(100)
    :ok
  end


  test "(re-) loading databases at start logs errors (kept as state)" do
    id = :initially_broken
    db = %{
      id:      id,
      adapter: MMDB2,
      source:  Path.join([ __DIR__, "does-not-exist" ])
    }

    assert capture_log(fn ->
      :ok = Application.put_env(:geolix, :databases, [ db ])
      :ok = restart_supervisor()

      # ensure GenServer.cast/1 was processed
      :timer.sleep(100)
    end) =~ "file not found"

    assert %{ id: ^id, state: { :error, _ }} =
           GenServer.call(Loader, { :get_database, db[:id] })

    assert Enum.member?(GenServer.call(Loader, :registered), db[:id])
    refute Enum.member?(GenServer.call(Loader, :loaded),     db[:id])
  end
end
