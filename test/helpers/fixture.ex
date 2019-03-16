defmodule Geolix.TestHelpers.Fixture do
  @moduledoc false

  alias Geolix.TestData.MMDB2Fixture

  @path Path.join([__DIR__, "../fixtures"])
  @fixtures [
    {:fixture_anonymous, "GeoIP2-Anonymous-IP-Test.mmdb"},
    {:fixture_asn, "GeoLite2-ASN-Test.mmdb"},
    {:fixture_city, "GeoIP2-City-Test.mmdb"},
    {:fixture_connection, "GeoIP2-Connection-Type-Test.mmdb"},
    {:fixture_country, "GeoIP2-Country-Test.mmdb"},
    {:fixture_domain, "GeoIP2-Domain-Test.mmdb"},
    {:fixture_enterprise, "GeoIP2-Enterprise-Test.mmdb"},
    {:fixture_isp, "GeoIP2-ISP-Test.mmdb"},
    {:fixture_broken_pointers, "MaxMind-DB-test-broken-pointers-24.mmdb"},
    {:fixture_no_ipv4_search_tree, "MaxMind-DB-no-ipv4-search-tree.mmdb"}
  ]

  def download do
    Enum.each(@fixtures, fn {_name, file} ->
      MMDB2Fixture.download(file, @path)
    end)
  end

  def list, do: @fixtures
end
