defmodule Geolix.Database.LoaderDelayedTest do
  use ExUnit.Case, async: true

  alias Geolix.Database.Loader

  defmodule DelayedAdapter do
    @behaviour Geolix.Adapter

    defmodule DelayedStorage do
      use Agent

      def start_link(_state), do: Agent.start_link(fn -> %{} end, name: __MODULE__)
      def get(action), do: Agent.get(__MODULE__, &Map.get(&1, action))
      def set(action, id), do: Agent.update(__MODULE__, &Map.put(&1, action, id))
    end

    def database_workers(_database) do
      [DelayedStorage.child_spec(%{})]
    end

    def load_database(_) do
      case DelayedStorage.get(:load_database) do
        nil ->
          DelayedStorage.set(:load_database, :initial)
          :delayed

        :initial ->
          DelayedStorage.set(:load_database, :final)
      end
    end

    def unload_database(%{id: id}), do: DelayedStorage.set(:unload_database, id)

    def lookup(_ip, _opts, _database), do: :ok
  end

  test "load/unload delayed" do
    id = :loader_delayed

    db = %{
      id: id,
      adapter: __MODULE__.DelayedAdapter
    }

    assert :delayed = Geolix.load_database(db)

    assert :initial = DelayedAdapter.DelayedStorage.get(:load_database)
    refute DelayedAdapter.DelayedStorage.get(:unload_database)

    assert %{id: ^id, state: :delayed} = Loader.get_database(id)

    assert id in Loader.registered_databases()
    refute id in Loader.loaded_databases()

    assert :ok = Geolix.load_database(db)

    assert :final = DelayedAdapter.DelayedStorage.get(:load_database)
    assert %{id: ^id, state: :loaded} = Loader.get_database(id)

    assert id in Loader.registered_databases()
    assert id in Loader.loaded_databases()

    assert :ok = Geolix.unload_database(id)
    assert ^id = DelayedAdapter.DelayedStorage.get(:unload_database)
  end
end
