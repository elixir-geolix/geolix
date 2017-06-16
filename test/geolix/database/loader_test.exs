defmodule Geolix.Database.LoaderTest do
  use ExUnit.Case, async: true

  alias Geolix.Adapter.Fake
  alias Geolix.Database.Loader


  test "fetching registered database information" do
    id       = :fixture_city
    database = GenServer.call(Loader, { :get_database, id })

    assert %{ id: ^id, state: :loaded } = database
  end

  test "fetching un-registered database information" do
    refute GenServer.call(Loader, { :get_database, :database_not_loaded })
  end


  test "error if configured without adapter" do
    id = :missing_adapter

    assert Geolix.load_database(%{ id: id }) ==
           { :error, { :config, :missing_adapter }}
  end

  test "error if configured with unknown (not loaded) adapter" do
    id = :unknown_adapter

    assert Geolix.load_database(%{ id: id, adapter: __MODULE__.Missing }) ==
           { :error, { :config, :unknown_adapter }}
  end


  test "load/unload lifecycle" do
    id = :lifecycle
    ip = { 8, 8, 8, 8 }

    Geolix.load_database(%{
      id:      id,
      adapter: Fake,
      data:    Map.put(%{}, ip, :fake_result)
    })

    assert :fake_result = Geolix.lookup(ip, where: id)

    Geolix.unload_database(id)

    refute Geolix.lookup(ip, where: id)
  end
end
