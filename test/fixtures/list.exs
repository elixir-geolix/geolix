defmodule Geolix.TestFixtures.List do
  @moduledoc false

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
      { :fixture_city, "GeoIP2-City-Test.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/GeoIP2-City-Test.mmdb" },
      { :fixture_connection, "GeoIP2-Connection-Type-Test.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/GeoIP2-Connection-Type-Test.mmdb" },
      { :fixture_country, "GeoIP2-Country-Test.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/GeoIP2-Country-Test.mmdb" },
      { :fixture_domain, "GeoIP2-Domain-Test.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/GeoIP2-Domain-Test.mmdb" },
      { :fixture_isp, "GeoIP2-ISP-Test.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/GeoIP2-ISP-Test.mmdb" },

      { :fixture_ipv4_24, "MaxMind-DB-test-ipv4-24.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/MaxMind-DB-test-ipv4-24.mmdb" },
      { :fixture_ipv4_28, "MaxMind-DB-test-ipv4-28.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/MaxMind-DB-test-ipv4-28.mmdb" },
      { :fixture_ipv4_32, "MaxMind-DB-test-ipv4-32.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/MaxMind-DB-test-ipv4-32.mmdb" },
      { :fixture_ipv6_24, "MaxMind-DB-test-ipv6-24.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/MaxMind-DB-test-ipv6-24.mmdb" },
      { :fixture_ipv6_28, "MaxMind-DB-test-ipv6-28.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/MaxMind-DB-test-ipv6-28.mmdb" },
      { :fixture_ipv6_32, "MaxMind-DB-test-ipv6-32.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/MaxMind-DB-test-ipv6-32.mmdb" }
    ]
  end
end
