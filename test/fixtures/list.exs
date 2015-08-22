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
      { :fixture_anonymous, "GeoIP-Anonymous-IP-Test.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/GeoIP2-Anonymous-IP-Test.mmdb" },
      { :fixture_city, "GeoIP2-City-Test.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/GeoIP2-City-Test.mmdb" },
      { :fixture_connection, "GeoIP2-Connection-Type-Test.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/GeoIP2-Connection-Type-Test.mmdb" },
      { :fixture_country, "GeoIP2-Country-Test.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/GeoIP2-Country-Test.mmdb" },
      { :fixture_domain, "GeoIP2-Domain-Test.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/GeoIP2-Domain-Test.mmdb" },
      { :fixture_isp, "GeoIP2-ISP-Test.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/GeoIP2-ISP-Test.mmdb" },
      { :fixture_precision_city, "GeoIP2-Precision-City-Test.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/GeoIP2-Precision-City-Test.mmdb" },
      { :fixture_precision_isp, "GeoIP2-Precision-ISP-Test.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/GeoIP2-Precision-ISP-Test.mmdb" },

      { :fixture_ipv4_24, "MaxMind-DB-test-ipv4-24.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/MaxMind-DB-test-ipv4-24.mmdb" },
      { :fixture_ipv4_28, "MaxMind-DB-test-ipv4-28.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/MaxMind-DB-test-ipv4-28.mmdb" },
      { :fixture_ipv4_32, "MaxMind-DB-test-ipv4-32.mmdb", "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data/MaxMind-DB-test-ipv4-32.mmdb" }
    ]
  end
end
