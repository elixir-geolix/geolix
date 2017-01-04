defmodule Geolix.Adapter.MMDB2.Result.AnonymousIPTest do
  use ExUnit.Case, async: true

  alias Geolix.Result.AnonymousIP

  test "result type" do
    assert %AnonymousIP{} = Geolix.lookup("1.2.0.0", where: :fixture_anonymous)
  end

  test "ipv6 lookup" do
    ip                  = "abcd:1000::"
    { :ok, ip_address } = ip |> String.to_char_list() |> :inet.parse_address()

    result   = Geolix.lookup(ip, where: :fixture_anonymous)
    expected = %AnonymousIP{ ip_address:      ip_address,
                             is_anonymous:    true,
                             is_public_proxy: true }

    assert result == expected
  end

  test "anonymous vpn" do
    ip       = { 1, 2, 0, 0 }
    result   = Geolix.lookup(ip, where: :fixture_anonymous)
    expected = %AnonymousIP{ ip_address:       ip,
                             is_anonymous:     true,
                             is_anonymous_vpn: true }

    assert result == expected
  end

  test "hosting provider" do
    ip       = { 71, 160, 223 ,0 }
    result   = Geolix.lookup(ip, where: :fixture_anonymous)
    expected = %AnonymousIP{ ip_address:          ip,
                             is_anonymous:        true,
                             is_hosting_provider: true }

    assert result == expected
  end

  test "public proxy" do
    ip       = { 186, 30, 236, 0 }
    result   = Geolix.lookup(ip, where: :fixture_anonymous)
    expected = %AnonymousIP{ ip_address:      ip,
                             is_anonymous:    true,
                             is_public_proxy: true }

    assert result == expected
  end

  test "tor exit node" do
    ip       = { 65, 0, 0, 0 }
    result   = Geolix.lookup(ip, where: :fixture_anonymous)
    expected = %AnonymousIP{ ip_address:       ip,
                             is_anonymous:     true,
                             is_tor_exit_node: true }

    assert result == expected
  end
end
