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
    databases = [
      %{ id: :error_missing_adapter },
      %{ id: :error_unknown_adapter, adapter: __MODULE__.Missing },
      %{
        id:      :error_enoent,
        adapter: MMDB2,
        source:  Path.join([ __DIR__, "does-not-exist" ])
      }
    ]

    log = capture_log(fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
      :ok = restart_supervisor()
    end)

    assert log =~ "file not found"
    assert log =~ "missing adapter"
    assert log =~ "unknown adapter"

    databases
    |> Enum.filter(&( Map.has_key?(&1, :id) ))
    |> Enum.each(fn (db) ->
         id = db[:id]

         assert %{ id: ^id, state: { :error, _ }} =
                GenServer.call(Loader, { :get_database, id })

         assert Enum.member?(GenServer.call(Loader, :registered), id)
         refute Enum.member?(GenServer.call(Loader, :loaded),     id)
       end)
  end
end
