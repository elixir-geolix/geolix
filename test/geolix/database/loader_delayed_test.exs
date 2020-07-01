defmodule Geolix.Database.LoaderDelayedTest do
  use ExUnit.Case, async: true

  alias Geolix.Database.Loader

  defmodule DelayedAdapter do
    @behaviour Geolix.Adapter

    def load_database(%{notify: pid}) do
      send(pid, :load_database)
      :delayed
    end

    def lookup(_, _, _), do: nil
  end

  test "load/unload delayed" do
    id = :loader_delayed
    db = %{id: id, adapter: DelayedAdapter, notify: self()}

    assert :delayed = Geolix.load_database(db)

    assert_receive :load_database

    assert %{id: ^id, state: :delayed} = Loader.get_database(id)
    assert id in Loader.registered_databases()
    refute id in Loader.loaded_databases()

    assert :ok = Geolix.unload_database(id)
  end
end
