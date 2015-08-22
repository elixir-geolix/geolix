defmodule Geolix.DatabaseTest do
  use ExUnit.Case, async: true

  alias Geolix.Database
  alias Geolix.Result
  alias Geolix.Storage.Metadata

  test "error if database contains no metadata" do
    path = Path.join([ __DIR__, "../fixtures/.gitignore" ]) |> Path.expand()

    assert { :error, :no_metadata } == Database.read_database(:invalid, path)
  end

  test "reloading a database" do
    path       = Path.join([ __DIR__, "../fixtures" ]) |> Path.expand()
    db_city    = Path.join([ path, "GeoIP2-City-Test.mmdb" ])
    db_country = Path.join([ path, "GeoIP2-Country-Test.mmdb" ])

    assert :ok = Geolix.set_database(:reload, db_city)
    assert %Result.City{} = Geolix.lookup("2.125.160.216", where: :reload)

    assert :ok = Geolix.set_database(:reload, db_country)
    assert %Result.Country{} = Geolix.lookup("2.125.160.216", where: :reload)
  end


  test "ipv4 24 bit record size" do
    result   = Geolix.lookup({ 1, 1, 1, 3 }, where: :fixture_ipv4_24)
    expected = %{ ip: "1.1.1.2", ip_address: { 1, 1, 1, 3 }}

    assert result == expected
    assert 24     == Metadata.get(:fixture_ipv4_24, :record_size)
  end

  test "ipv4 28 bit record size" do
    result   = Geolix.lookup({ 1, 1, 1, 3 }, where: :fixture_ipv4_28)
    expected = %{ ip: "1.1.1.2", ip_address: { 1, 1, 1, 3 }}

    assert result == expected
    assert 28     == Metadata.get(:fixture_ipv4_28, :record_size)
  end

  test "ipv4 32 bit record size" do
    result   = Geolix.lookup({ 1, 1, 1, 3 }, where: :fixture_ipv4_32)
    expected = %{ ip: "1.1.1.2", ip_address: { 1, 1, 1, 3 }}

    assert result == expected
    assert 32     == Metadata.get(:fixture_ipv4_32, :record_size)
  end
end
