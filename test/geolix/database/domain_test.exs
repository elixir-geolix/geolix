defmodule Geolix.Database.DomainTest do
  use ExUnit.Case, async: true

  alias Geolix.Database
  alias Geolix.MetadataStorage

  @db Path.join([ __DIR__, "../../fixtures/GeoIP2-Domain-Test.mmdb" ]) |> Path.expand()

  { _, tree, data, meta } = Database.read_db(@db)

  @data data
  @meta meta
  @tree tree

  test "reading domain" do
    MetadataStorage.set(@db, @meta)

    expected = %{ city: %{ domain: "maxmind.com" }, country: nil }
    database = %{ cities:    %{ filename: @db, tree: @tree, data: @data },
                  countries: nil }

    assert expected == Database.lookup({ 1, 2, 0, 0 }, database)
  end
end
