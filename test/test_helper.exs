Code.require_file("fixtures/list.exs", __DIR__)
Code.require_file("fixtures/download.exs", __DIR__)


Geolix.TestFixtures.Download.run()

Geolix.TestFixtures.List.get() |> Enum.each fn({ name, filename, _remote}) ->
    path =
         [ __DIR__, "fixtures", filename ]
      |> Path.join()
      |> Path.expand()

    Geolix.set_database(name, path)
end


ExUnit.start()
