defmodule Geolix.TestFixtures.List do
  @moduledoc false

  @base_url "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data"

  @doc """
  Returns a list of all available/downloaded fixtures.

  Each returned entry consists of the following values:

      {
        :name_as_atom,
        "local_filename.mmdb",
        "remote_url"
      }
  """
  @spec get() :: list
  def get() do
    [
      { :fixture_anonymous, "GeoIP-Anonymous-IP-Test.mmdb", "#{ @base_url }/GeoIP2-Anonymous-IP-Test.mmdb" },
      { :fixture_city, "GeoIP2-City-Test.mmdb", "#{ @base_url }/GeoIP2-City-Test.mmdb" },
      { :fixture_connection, "GeoIP2-Connection-Type-Test.mmdb", "#{ @base_url }/GeoIP2-Connection-Type-Test.mmdb" },
      { :fixture_country, "GeoIP2-Country-Test.mmdb", "#{ @base_url }/GeoIP2-Country-Test.mmdb" },
      { :fixture_domain, "GeoIP2-Domain-Test.mmdb", "#{ @base_url }/GeoIP2-Domain-Test.mmdb" },
      { :fixture_enterprise, "GeoIP2-Enterprise-Test.mmdb", "#{ @base_url }/GeoIP2-Enterprise-Test.mmdb" },
      { :fixture_isp, "GeoIP2-ISP-Test.mmdb", "#{ @base_url }/GeoIP2-ISP-Test.mmdb" },
      { :fixture_precision_city, "GeoIP2-Precision-City-Test.mmdb", "#{ @base_url }/GeoIP2-Precision-City-Test.mmdb" },
      { :fixture_precision_isp, "GeoIP2-Precision-ISP-Test.mmdb", "#{ @base_url }/GeoIP2-Precision-ISP-Test.mmdb" },

      { :fixture_decoder, "MaxMind-DB-test-decoder.mmdb", "#{ @base_url }/MaxMind-DB-test-decoder.mmdb" },
      { :fixture_ipv4_24, "MaxMind-DB-test-ipv4-24.mmdb", "#{ @base_url }/MaxMind-DB-test-ipv4-24.mmdb" },
      { :fixture_ipv4_28, "MaxMind-DB-test-ipv4-28.mmdb", "#{ @base_url }/MaxMind-DB-test-ipv4-28.mmdb" },
      { :fixture_ipv4_32, "MaxMind-DB-test-ipv4-32.mmdb", "#{ @base_url }/MaxMind-DB-test-ipv4-32.mmdb" },
      { :fixture_ipv6_24, "MaxMind-DB-test-ipv6-24.mmdb", "#{ @base_url }/MaxMind-DB-test-ipv6-24.mmdb" },
      { :fixture_ipv6_28, "MaxMind-DB-test-ipv6-28.mmdb", "#{ @base_url }/MaxMind-DB-test-ipv6-28.mmdb" },
      { :fixture_ipv6_32, "MaxMind-DB-test-ipv6-32.mmdb", "#{ @base_url }/MaxMind-DB-test-ipv6-32.mmdb" },

      { :fixture_broken_pointers, "MaxMind-DB-test-broken-pointers-24.mmdb", "#{ @base_url }/MaxMind-DB-test-broken-pointers-24.mmdb" },
      { :fixture_no_ipv4_search_tree, "MaxMind-DB-no-ipv4-search-tree.mmdb", "#{ @base_url }/MaxMind-DB-no-ipv4-search-tree.mmdb" }
    ]
  end
end
