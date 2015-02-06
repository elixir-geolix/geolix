defmodule GeolixTest do
  use ExUnit.Case, async: false

  test "result type" do
    assert %{} = Geolix.lookup("81.2.69.160", :fixture_city, as: :raw)
    assert %{} = Geolix.lookup("81.2.69.160", :fixture_city, as: :struct)
  end

  test "lookup returns ip address" do
    ip     = { 1, 2, 0, 0 }
    result = Geolix.lookup(ip, :fixture_domain)

    assert ip == result.ip_address
  end

  test "lookup finds no entry" do
    assert nil == Geolix.lookup("10.10.10.10", :fixture_city)
    assert nil == Geolix.lookup("10.10.10.10", :fixture_country)

    lookup = Geolix.lookup("10.10.10.10")

    assert nil == lookup[:fixture__city]
    assert nil == lookup[:fixture__country]
  end

  test "lookup from unregistered database" do
    assert nil == Geolix.lookup("127.0.0.1", :unknown_database)
  end

  test "set database with invalid filename" do
    assert { :error, _ } = Geolix.set_database(:unknown_database, "invalid")
  end
end
