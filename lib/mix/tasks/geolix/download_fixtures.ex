defmodule Mix.Tasks.Geolix.Fixtures do
  @moduledoc """
  Fetches fixture databases used in tests from the official
  [MaxMind-DB](https://github.com/maxmind/MaxMind-DB) project.

  The files will be stored inside the `tests/fixtures/` folder.
  """

  use Mix.Task

  @shortdoc "Downloads fixture databases for tests"

  @doc """
  Returns a list of all available/downloaded fixtures.

  Each returned entry consists of the following values:

      {
        :name_as_atom,
        "local_filename.mmdb",
        "remote_url"
      }
  """
  @spec list() :: list
  def list do
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

  def run(_args) do
    Enum.each(list(), &download/1)
  end

  defp download({ _name, filename, remote }) do
    local = local(filename)

    if not File.regular?(local) do
      Mix.shell.info [ :yellow, "Downloading fixture database: #{ filename }" ]
      File.write! local, Mix.Utils.read_path!(remote)
    end
  end

  defp local(filename) do
    [ __DIR__, "../../../../test/fixtures", filename ]
      |> Path.join()
      |> Path.expand()
  end
end
