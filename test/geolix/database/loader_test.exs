defmodule Geolix.Database.LoaderTest do
  use ExUnit.Case, async: false

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

  test "load/reload/unload lifecycle" do
    id = :loader_lifecycle
    db = %{id: id, adapter: LifecycleAdapter, notify: self()}

    refute Loader.get_database(:database_not_loaded)

    assert :ok = Geolix.load_database(db)
    assert :ok = Geolix.reload_databases()

    assert_receive :load_database
    assert_receive :load_database

    assert %{id: ^id, state: :loaded} = Loader.get_database(id)

    assert id in Loader.registered_databases()
    assert id in Loader.loaded_databases()

    assert :ok = Geolix.unload_database(db)

    assert_receive :unload_database
  end
end
