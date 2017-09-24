defmodule Geolix.Adapter.MMDB2.Result.ConnectionTypeTest do
  use ExUnit.Case, async: true

  alias Geolix.Result.ConnectionType


  test "result type" do
    assert %ConnectionType{} = Geolix.lookup("1.0.0.0", where: :fixture_connection)
  end

  test "ipv6 lookup" do
    ip                  = "2003::"
    { :ok, ip_address } = ip |> String.to_charlist() |> :inet.parse_address()

    result   = Geolix.lookup(ip, where: :fixture_connection)
    expected = %ConnectionType{ connection_type: "Cable/DSL",
                                ip_address:      ip_address }

    assert result == expected
  end

  test "cable/dsl" do
    ip       = { 1, 0, 1, 0 }
    result   = Geolix.lookup(ip, where: :fixture_connection)
    expected = %ConnectionType{ connection_type: "Cable/DSL",
                                ip_address:      ip }

    assert result == expected
  end

  test "corporate" do
    ip       = { 201, 243, 200, 0 }
    result   = Geolix.lookup(ip, where: :fixture_connection)
    expected = %ConnectionType{ connection_type: "Corporate",
                                ip_address:      ip }

    assert result == expected
  end

  test "cellular" do
    ip       = { 80, 214, 0, 0 }
    result   = Geolix.lookup(ip, where: :fixture_connection)
    expected = %ConnectionType{ connection_type: "Cellular",
                                ip_address:      ip }

    assert result == expected
  end

  test "dialup" do
    ip       = { 1, 0, 2, 0 }
    result   = Geolix.lookup(ip, where: :fixture_connection)
    expected = %ConnectionType{ connection_type: "Dialup",
                                ip_address:      ip }

    assert result == expected
  end
end
