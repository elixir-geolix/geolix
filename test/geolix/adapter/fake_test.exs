defmodule Geolix.Adapter.FakeTest do
  use ExUnit.Case, async: true

  alias Geolix.Adapter.Fake

  doctest Fake

  defmodule MFArgsSender do
    def notify(%{notify: pid} = database), do: send(pid, database)
    def notify(%{notify: pid}, extra_arg), do: send(pid, extra_arg)
  end

  test "fake adapter (loading) lifecycle" do
    ip = {42, 42, 42, 42}
    result = %{test: :result}
    lifecycle_id = :test_fake_adapter_lifecycle

    lifecycle_db = %{
      id: lifecycle_id,
      adapter: Fake,
      data: %{ip => result}
    }

    refute Geolix.lookup(ip, where: lifecycle_id)
    refute Geolix.metadata(where: lifecycle_id)

    Geolix.load_database(lifecycle_db)

    assert ^result = Geolix.lookup(ip, where: lifecycle_id)
    assert %{load_epoch: _} = Geolix.metadata(where: lifecycle_id)

    Geolix.unload_database(lifecycle_db)

    refute Geolix.lookup(ip, where: lifecycle_id)
    refute Geolix.metadata(where: lifecycle_id)
  end

  test "fake adapter mfargs using {mod, fun}", %{test: test} do
    database = %{
      id: test,
      adapter: Fake,
      data: %{},
      mfargs_load_database: {MFArgsSender, :notify},
      mfargs_unload_database: {MFArgsSender, :notify},
      notify: self()
    }

    Geolix.load_database(database)
    Geolix.unload_database(database)

    assert_receive %{id: ^test}
    assert_receive %{id: ^test}
  end

  test "fake adapter mfargs using {mod, fun, extra_args}", %{test: test} do
    database = %{
      id: test,
      adapter: Fake,
      data: %{},
      mfargs_load_database: {MFArgsSender, :notify, [:load_database]},
      mfargs_unload_database: {MFArgsSender, :notify, [:unload_database]},
      notify: self()
    }

    Geolix.load_database(database)
    Geolix.unload_database(database)

    assert_receive :load_database
    assert_receive :unload_database
  end
end
