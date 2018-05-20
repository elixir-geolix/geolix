alias Geolix.Adapter.MMDB2
alias Geolix.TestHelpers.FixtureDownload
alias Geolix.TestHelpers.FixtureList

FixtureDownload.run()

databases =
  [
    %{
      id: :testdata_gz,
      adapter: MMDB2,
      source: Path.join([Geolix.TestData.dir(:mmdb2), "Geolix.mmdb.gz"])
    },
    %{
      id: :testdata_plain,
      adapter: MMDB2,
      source: Path.join([Geolix.TestData.dir(:mmdb2), "Geolix.mmdb"])
    },
    %{
      id: :testdata_tar,
      adapter: MMDB2,
      source: Path.join([Geolix.TestData.dir(:mmdb2), "Geolix.mmdb.tar"])
    },
    %{
      id: :testdata_targz,
      adapter: MMDB2,
      source: Path.join([Geolix.TestData.dir(:mmdb2), "Geolix.mmdb.tar.gz"])
    }
  ] ++
    Enum.map(FixtureList.get(), fn {id, filename, _remote} ->
      source =
        [__DIR__, "fixtures", filename]
        |> Path.join()
        |> Path.expand()

      %{id: id, adapter: MMDB2, source: source}
    end)

Application.put_env(:geolix, :databases, databases)
Enum.each(databases, &Geolix.load_database/1)

ExUnit.start()
