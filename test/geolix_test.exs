defmodule GeolixTest do
  use ExUnit.Case, async: false

  test "result type" do
    ip    = "81.2.69.160"
    where = :fixture_city

    assert %{}                   = Geolix.lookup(ip, as: :raw,    where: where)
    assert %Geolix.Result.City{} = Geolix.lookup(ip, as: :struct, where: where)
  end

  test "lookup returns ip address" do
    ip     = { 1, 2, 0, 0 }
    result = Geolix.lookup(ip, where: :fixture_domain)

    assert ip == result.ip_address
  end

  test "lookup finds no entry" do
    ip = "10.10.10.10"

    assert nil == Geolix.lookup(ip, where: :fixture_city)
    assert nil == Geolix.lookup(ip, where: :fixture_country)

    lookup = Geolix.lookup(ip)

    assert nil == lookup[:fixture__city]
    assert nil == lookup[:fixture__country]
  end

  test "lookup from all registered databases" do
    results = Geolix.lookup("81.2.69.160")

    assert %Geolix.Result.City{}    = results[:fixture_city]
    assert %Geolix.Result.Country{} = results[:fixture_country]
  end

  test "lookup from unregistered database" do
    assert nil == Geolix.lookup("127.0.0.1", where: :unknown_database)
  end

  test "set database with invalid filename" do
    assert { :error, _ } = Geolix.set_database(:unknown_database, "invalid")
  end
end
