Code.require_file("fixtures/list.exs", __DIR__)
Code.require_file("fixtures/download.exs", __DIR__)

alias Geolix.Adapter.MMDB2
alias Geolix.TestFixtures


TestFixtures.Download.run()


databases = Enum.map TestFixtures.List.get(), fn ({ id, filename, _remote }) ->
  source =
    [ __DIR__, "fixtures", filename ]
    |> Path.join()
    |> Path.expand()

  %{ id: id, adapter: MMDB2, source: source }
end

Application.put_env(:geolix, :databases, databases)
Enum.each(databases, &Geolix.load_database/1)


ExUnit.start()
