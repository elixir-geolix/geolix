defmodule Geolix.Adapter.MMDB2.Result.DomainTest do
  use ExUnit.Case, async: true

  alias Geolix.Result.Domain


  test "result type" do
    assert %Domain{} = Geolix.lookup("1.2.0.0", where: :fixture_domain)
  end

  test "ipv6 lookup" do
    ip                  = "2a02:8420:48f4:b000::"
    { :ok, ip_address } = ip |> String.to_charlist() |> :inet.parse_address()

    result   = Geolix.lookup(ip, where: :fixture_domain)
    expected = %Domain{ domain:     "sfr.net",
                        ip_address: ip_address }

    assert result == expected
  end

  test "domain" do
    ip       = { 1, 2, 0, 0 }
    result   = Geolix.lookup(ip, where: :fixture_domain)
    expected = %Domain{ domain:     "maxmind.com",
                        ip_address: ip }

    assert result == expected
  end
end
