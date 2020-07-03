defmodule Geolix.Database.LoaderTest do
  use ExUnit.Case, async: true

  alias Geolix.Database.Loader

  defmodule LifecycleAdapter do
    @behaviour Geolix.Adapter

    def load_database(%{notify: pid}) do
      send(pid, :load_database)
      :ok
    end

    def unload_database(%{notify: pid}) do
      send(pid, :unload_database)
      :ok
    end

    def lookup(_, _, _), do: nil
  end

  test "fetching un-registered database information" do
    refute Loader.get_database(:database_not_loaded)
  end

  test "error if configured without adapter" do
    id = :missing_adapter
    db = %{id: id}

    assert {:error, {:config, :missing_adapter}} = Geolix.load_database(db)
  end

  test "error if configured with unknown (not loaded) adapter" do
    id = :unknown_adapter
    db = %{id: id, adapter: __MODULE__.Missing}

    assert {:error, {:config, :unknown_adapter}} = Geolix.load_database(db)
  end

  test "load/unload lifecycle" do
    id = :loader_lifecycle
    db = %{id: id, adapter: LifecycleAdapter, notify: self()}

    assert :ok = Geolix.load_database(db)

    assert_receive :load_database

    assert %{id: ^id, state: :loaded} = Loader.get_database(id)

    assert id in Loader.registered_databases()
    assert id in Loader.loaded_databases()

    assert :ok = Geolix.unload_database(db)

    assert_receive :unload_database
  end
end
