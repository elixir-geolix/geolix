defmodule Mix.Tasks.Geolix.Fixtures do
  @moduledoc """
  Fetches fixture databases used in tests from the official
  [MaxMind-DB](https://github.com/maxmind/MaxMind-DB) project.

  The files will be stored inside the `tests/fixtures/` folder.
  """

  use Mix.Task

  @shortdoc "Downloads fixture databases for tests"
  @fixtures [
    { "GeoIP2-City-Test.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/GeoIP2-City-Test.mmdb" },
    { "GeoIP2-Country-Test.mmdb", "https://github.com/maxmind/MaxMind-DB/raw/master/test-data/GeoIP2-Country-Test.mmdb" }
  ]

  def run(_args) do
    Enum.each(@fixtures, &download/1)
  end

  defp download({ filename, remote }) do
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
