defmodule Geolix.Database.LoaderTest do
  use ExUnit.Case, async: true

  alias Geolix.Database.Loader

  defmodule LifecycleAdapter do
    @behaviour Geolix.Adapter

    defmodule LifecycleStorage do
      use Agent

      def start_link(_state), do: Agent.start_link(fn -> %{} end, name: __MODULE__)
      def get(action), do: Agent.get(__MODULE__, &Map.get(&1, action))
      def set(action, id), do: Agent.update(__MODULE__, &Map.put(&1, action, id))
    end

    def database_workers(_database) do
      [LifecycleStorage.child_spec(%{})]
    end

    def load_database(%{id: id}), do: LifecycleStorage.set(:load_database, id)
    def unload_database(%{id: id}), do: LifecycleStorage.set(:unload_database, id)

    def lookup(_ip, _opts, _database), do: :ok
  end

  test "fetching un-registered database information" do
    refute Loader.get_database(:database_not_loaded)
  end

  test "error if configured without adapter" do
    id = :missing_adapter
    db = %{id: id}

    assert Geolix.load_database(db) == {:error, {:config, :missing_adapter}}
  end

  test "error if configured with unknown (not loaded) adapter" do
    id = :unknown_adapter
    db = %{id: id, adapter: __MODULE__.Missing}

    assert Geolix.load_database(db) == {:error, {:config, :unknown_adapter}}
  end

  test "load/unload lifecycle" do
    id = :loader_lifecycle

    db = %{
      id: id,
      adapter: __MODULE__.LifecycleAdapter
    }

    assert :ok = Geolix.load_database(db)

    assert ^id = LifecycleAdapter.LifecycleStorage.get(:load_database)
    refute LifecycleAdapter.LifecycleStorage.get(:unload_database)

    assert %{id: ^id, state: :loaded} = Loader.get_database(id)

    assert id in Loader.registered_databases()
    assert id in Loader.loaded_databases()

    assert :ok = Geolix.unload_database(id)
    assert ^id = LifecycleAdapter.LifecycleStorage.get(:unload_database)
  end
end
