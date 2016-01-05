defmodule Geolix.Database.LoaderTest do
  use ExUnit.Case, async: true

  alias Geolix.Result

  test "error if database contains no metadata" do
    path = Path.join([ __DIR__, "../../fixtures/.gitignore" ]) |> Path.expand()

    assert { :error, :no_metadata } == Geolix.set_database(:invalid, path)
  end

  test "reloading a database" do
    path       = Path.join([ __DIR__, "../../fixtures" ]) |> Path.expand()
    db_city    = Path.join([ path, "GeoIP2-City-Test.mmdb" ])
    db_country = Path.join([ path, "GeoIP2-Country-Test.mmdb" ])

    assert :ok = Geolix.set_database(:reload, db_city)
    assert %Result.City{} = Geolix.lookup("2.125.160.216", where: :reload)

    assert :ok = Geolix.set_database(:reload, db_country)
    assert %Result.Country{} = Geolix.lookup("2.125.160.216", where: :reload)
  end
end
