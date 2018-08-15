defmodule Geolix.Adapter.MMDB2.Result.ASNTest do
  use ExUnit.Case, async: true

  alias Geolix.Adapter.MMDB2.Result.ASN

  test "result type" do
    assert %ASN{} = Geolix.lookup("1.128.0.0", where: :fixture_asn)
  end

  test "ipv4 lookup" do
    ip = {1, 128, 0, 0}
    result = Geolix.lookup(ip, where: :fixture_asn)

    expected = %ASN{
      ip_address: ip,
      autonomous_system_number: 1221,
      autonomous_system_organization: "Telstra Pty Ltd"
    }

    assert result == expected
  end

  test "ipv6 lookup" do
    ip = "2600:6000::"
    {:ok, ip_address} = ip |> String.to_charlist() |> :inet.parse_address()

    result = Geolix.lookup(ip, where: :fixture_asn)

    expected = %ASN{
      ip_address: ip_address,
      autonomous_system_number: 237,
      autonomous_system_organization: "Merit Network Inc."
    }

    assert result == expected
  end
end
