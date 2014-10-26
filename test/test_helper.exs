Mix.Task.run("geolix.fixtures")

Enum.each(
  Mix.Tasks.Geolix.Fixtures.list(),
  fn ({ name, filename, _remote }) ->
    path = Path.join([ __DIR__, "fixtures", filename ]) |> Path.expand()

    Geolix.set_database(name, path)
  end
)


ExUnit.start()
