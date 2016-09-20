defmodule GeolixTest do
  use ExUnit.Case, async: true

  test "result type" do
    ip    = "81.2.69.160"
    where = :fixture_city

    assert %{}                   = Geolix.lookup(ip, as: :raw,    where: where)
    assert %Geolix.Result.City{} = Geolix.lookup(ip, as: :struct, where: where)
  end

  test "ipv4 lookup in ipv6 notation" do
    ipv4 = "81.2.69.160"
    ipv6 = "0:0:0:0:0:ffff:5102:45a0"

    ipv4_result =
         ipv4
      |> Geolix.lookup(as: :raw, where: :fixture_city)
      |> Map.put(:ip_address, nil)

    ipv6_result =
         ipv6
      |> Geolix.lookup(as: :raw, where: :fixture_city)
      |> Map.put(:ip_address, nil)

    assert ipv4_result == ipv6_result
  end

  test "ipv6 lookup in ipv4 database" do
    assert nil == Geolix.lookup("2001::", where: :fixture_ipv4_32)
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

  test "lookup using timeout" do
    ip     = "81.2.69.160"
    opts   = [ where: :fixture_city, timeout: 50 ]
    result = Geolix.lookup(ip, opts)

    assert %Geolix.Result.City{} = result
  end
end
