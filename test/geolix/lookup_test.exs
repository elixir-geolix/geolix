defmodule Geolix.LookupTest do
  use ExUnit.Case, async: true

  alias Geolix.Adapter.Fake

  test "database lookup" do
    ip = {42, 42, 42, 42}

    result_first = %{test: :first}
    result_second = %{test: :second}

    db_first = %{id: :test_lookup_first, adapter: Fake, data: %{ip => result_first}}
    db_second = %{id: :test_lookup_second, adapter: Fake, data: %{ip => result_second}}

    :ok = Geolix.load_database(db_first)
    :ok = Geolix.load_database(db_second)

    assert ^result_first = Geolix.lookup(ip, where: :test_lookup_first)
    assert ^result_second = Geolix.lookup(ip, where: :test_lookup_second)

    assert %{
             test_lookup_first: ^result_first,
             test_lookup_second: ^result_second
           } = Geolix.lookup(ip)

    Geolix.unload_database(db_first)
    Geolix.unload_database(db_second)
  end
end
