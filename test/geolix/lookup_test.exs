defmodule Geolix.LookupTest do
  use ExUnit.Case, async: true

  @ip {42, 42, 42, 42}

  @result_first %{test: :first}
  @result_second %{test: :second}

  @db_first %{
    id: :test_lookup_first,
    adapter: Geolix.Adapter.Fake,
    data: %{@ip => @result_first}
  }

  @db_second %{
    id: :test_lookup_second,
    adapter: Geolix.Adapter.Fake,
    data: %{@ip => @result_second}
  }

  setup do
    :ok = Geolix.load_database(@db_first)
    :ok = Geolix.load_database(@db_second)
    :ok
  end

  test "single database lookup" do
    assert @result_first == Geolix.lookup(@ip, where: :test_lookup_first)
    assert @result_second == Geolix.lookup(@ip, where: :test_lookup_second)
  end

  test "multi database lookup" do
    assert %{
             test_lookup_first: @result_first,
             test_lookup_second: @result_second
           } = Geolix.lookup(@ip)
  end
end
