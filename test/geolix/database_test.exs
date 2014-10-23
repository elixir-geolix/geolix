defmodule Geolix.DatabaseTest do
  use ExUnit.Case, async: true

  @db_city    Path.join([ __DIR__, "../fixtures/GeoIP2-City-Test.mmdb" ]) |> Path.expand()
  @db_country Path.join([ __DIR__, "../fixtures/GeoIP2-Country-Test.mmdb" ]) |> Path.expand()

  { _, tree_city, data_city, meta_city } = Geolix.Database.read_db(@db_city)

  @data_city data_city
  @meta_city meta_city
  @tree_city tree_city

  { _, tree_country, data_country, meta_country } = Geolix.Database.read_db(@db_country)

  @data_country data_country
  @meta_country meta_country
  @tree_country tree_country

  test "reading city database" do
    assert "GeoIP2-City" == @meta_city.database_type
  end

  test "reading country database" do
    assert "GeoIP2-Country" == @meta_country.database_type
  end
end
