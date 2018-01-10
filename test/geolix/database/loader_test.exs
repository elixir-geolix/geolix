defmodule Geolix.Database.LoaderTest do
  use ExUnit.Case, async: true

  alias Geolix.Database.Loader

  @lifecycle_id :loader_lifecycle
  @lifecycle_db %{
    id: @lifecycle_id,
    adapter: __MODULE__.LifecycleAdapter
  }

  defmodule LifecycleAdapter do
    @behaviour Geolix.Adapter

    defmodule LifecycleStorage do
      def start_link(), do: Agent.start_link(fn -> %{} end, name: __MODULE__)
      def get(action), do: Agent.get(__MODULE__, &Map.get(&1, action))
      def set(action, id), do: Agent.update(__MODULE__, &Map.put(&1, action, id))
    end

    def database_workers() do
      import Supervisor.Spec

      [worker(LifecycleStorage, [])]
    end

    def load_database(%{id: id}), do: LifecycleStorage.set(:load_database, id)
    def unload_database(%{id: id}), do: LifecycleStorage.set(:unload_database, id)

    def lookup(_ip, _opts), do: :ok
  end

  test "fetching registered database information" do
    id = :fixture_city
    database = GenServer.call(Loader, {:get_database, id})

    assert %{id: ^id, state: :loaded} = database
  end

  test "fetching un-registered database information" do
    refute GenServer.call(Loader, {:get_database, :database_not_loaded})
  end

  test "error if configured without adapter" do
    id = :missing_adapter

    assert Geolix.load_database(%{id: id}) == {:error, {:config, :missing_adapter}}
  end

  test "error if configured with unknown (not loaded) adapter" do
    id = :unknown_adapter

    assert Geolix.load_database(%{id: id, adapter: __MODULE__.Missing}) ==
             {:error, {:config, :unknown_adapter}}
  end

  test "load/unload lifecycle" do
    assert :ok = Geolix.load_database(@lifecycle_db)

    assert @lifecycle_id = LifecycleAdapter.LifecycleStorage.get(:load_database)
    refute LifecycleAdapter.LifecycleStorage.get(:unload_database)

    assert :ok = Geolix.unload_database(@lifecycle_id)

    assert @lifecycle_id = LifecycleAdapter.LifecycleStorage.get(:unload_database)
  end
end
