defmodule Geolix.Adapter.MMDB2.DatabaseTest do
  use ExUnit.Case, async: true

  alias Geolix.Adapter.MMDB2.Database
  alias Geolix.Adapter.MMDB2.Storage.Metadata


  test "empty :where defaults to nil result" do
    assert nil == Database.lookup("8.8.8.8", [])
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


  test "ipv6 24 bit record size" do
    result   = Geolix.lookup("::2:0:41", where: :fixture_ipv6_24)
    expected = %{ ip: "::2:0:40", ip_address: { 0, 0, 0, 0, 0, 2, 0, 65 }}

    assert result == expected
    assert 24     == Metadata.get(:fixture_ipv6_24, :record_size)
  end

  test "ipv6 28 bit record size" do
    result   = Geolix.lookup("::2:0:41", where: :fixture_ipv6_28)
    expected = %{ ip: "::2:0:40", ip_address: { 0, 0, 0, 0, 0, 2, 0, 65 }}

    assert result == expected
    assert 28     == Metadata.get(:fixture_ipv6_28, :record_size)
  end

  test "ipv6 32 bit record size" do
    result   = Geolix.lookup("::2:0:41", where: :fixture_ipv6_32)
    expected = %{ ip: "::2:0:40", ip_address: { 0, 0, 0, 0, 0, 2, 0, 65 }}

    assert result == expected
    assert 32     == Metadata.get(:fixture_ipv6_32, :record_size)
  end
end
