defmodule GeolixTest do
  use ExUnit.Case, async: false

  test "lookup connection type entry" do
    result = Geolix.lookup(:fixture_connection, "1.0.1.0")

    assert "Cable/DSL" == result[:connection_type]
  end

  test "lookup domain entry" do
    result = Geolix.lookup(:fixture_domain, "1.2.0.0")

    assert "maxmind.com" == result[:domain]
  end

  test "lookup isp entry" do
    result = Geolix.lookup(:fixture_isp, "1.128.0.0")

    assert 1221 == result[:autonomous_system_number]
    assert "Telstra Pty Ltd" == result[:autonomous_system_organization]
    assert "Telstra Internet" == result[:isp]
    assert "Telstra Internet" == result[:organization]
  end

  test "lookup returns ip address" do
    ip     = { 1, 2, 0, 0 }
    result = Geolix.lookup(:fixture_domain, ip)

    assert ip == result[:ip]
  end

  test "lookup finds no entry" do
    assert nil == Geolix.lookup(:fixture_city,    "10.10.10.10")
    assert nil == Geolix.lookup(:fixture_country, "10.10.10.10")

    lookup = Geolix.lookup("10.10.10.10")

    assert nil == lookup[:fixture__city]
    assert nil == lookup[:fixture__country]
  end

  test "lookup from unregistered database" do
    assert nil == Geolix.lookup(:database, "127.0.0.1")
  end

  test "set database with invalid filename" do
    assert { :error, _ } = Geolix.set_database(:database, "invalid")
  end
end
