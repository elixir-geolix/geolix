defmodule Geolix.Database.DomainTest do
  use ExUnit.Case, async: true

  test "reading domain" do
    db_file = Path.join([ __DIR__, "../../fixtures/GeoIP2-Domain-Test.mmdb" ]) |> Path.expand()
    db_name = :database_domain

    Geolix.set_database(db_name, db_file)

    assert %{ domain: "maxmind.com" } == Geolix.lookup(db_name, { 1, 2, 0, 0 })
  end
end
