defmodule Geolix.ReloadTest do
  use ExUnit.Case, async: false

  alias Geolix.Adapter.MMDB2.Metadata
  alias Geolix.Adapter.MMDB2.Storage.Metadata, as: MetadataStorage

  alias Geolix.Database.Supervisor, as: DatabaseSupervisor


  setup do
    databases = Application.get_env(:geolix, :databases)
    database  =
      databases
      |> Enum.filter(&( &1.id == :fixture_city ))
      |> List.first()

    :ok = Application.put_env(:geolix, :databases, [ database ])
    :ok = restart_supervisor()

    on_exit fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
      :ok = restart_supervisor
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


  test "reload databases" do
    ip    = "81.2.69.160"
    where = :fixture_city

    # break lookup tree
    MetadataStorage.set(where, %Metadata{})

    assert nil == Geolix.lookup(ip, where: where)

    # reload to fix lookup
    Geolix.reload_databases()
    :timer.sleep(500)

    refute nil == Geolix.lookup(ip, where: where)
  end
end
