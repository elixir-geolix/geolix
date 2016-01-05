Code.require_file("fixtures/list.exs", __DIR__)
Code.require_file("fixtures/download.exs", __DIR__)

alias Geolix.TestFixtures


TestFixtures.Download.run()

Enum.each TestFixtures.List.get(), fn ({ name, filename, _remote }) ->
  databases = Application.get_env(:geolix, :databases, [])
  path      =
       [ __DIR__, "fixtures", filename ]
    |> Path.join()
    |> Path.expand()

  databases = Keyword.put(databases, name, path)

  Application.put_env(:geolix, :databases, databases)
end


# Silent restart
Logger.remove_backend(:console)
Application.stop(:geolix)
Application.ensure_all_started(:geolix)
Logger.add_backend(:console, flush: true)


ExUnit.start()
