defmodule Geolix.DatabaseTest do
  use ExUnit.Case, async: true

  alias Geolix.Database
  alias Geolix.MetadataStorage

  @db_city    Path.join([ __DIR__, "../fixtures/GeoIP2-City-Test.mmdb" ]) |> Path.expand()
  @db_country Path.join([ __DIR__, "../fixtures/GeoIP2-Country-Test.mmdb" ]) |> Path.expand()

  { _, tree_city, data_city, meta_city } = Database.read_db(@db_city)

  @data_city data_city
  @meta_city meta_city
  @tree_city tree_city

  { _, tree_country, data_country, meta_country } = Database.read_db(@db_country)

  @data_country data_country
  @meta_country meta_country
  @tree_country tree_country

  test "reading city database" do
    assert "GeoIP2-City" == @meta_city.database_type
  end

  test "reading country database" do
    assert "GeoIP2-Country" == @meta_country.database_type
  end

  test "no entry found" do
    MetadataStorage.set(@db_city,    @meta_city)
    MetadataStorage.set(@db_country, @meta_country)

    expected = %{ city: nil, country: nil }
    database = %{ cities:    %{ filename: @db_city,    tree: @tree_city,    data: @data_city },
                  countries: %{ filename: @db_country, tree: @tree_country, data: @data_country }}

    assert expected == Database.lookup({ 10, 10, 10, 10 }, database)
  end
end
