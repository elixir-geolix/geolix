defmodule Geolix.DatabaseTest do
  use ExUnit.Case, async: true

  alias Geolix.MetadataStorage

  @db_file_city    Path.join([ __DIR__, "../fixtures/GeoIP2-City-Test.mmdb" ]) |> Path.expand()
  @db_file_country Path.join([ __DIR__, "../fixtures/GeoIP2-Country-Test.mmdb" ]) |> Path.expand()
  @db_name_city    :database_city
  @db_name_country :database_country

  Geolix.set_database(@db_name_city,    @db_file_city)
  Geolix.set_database(@db_name_country, @db_file_country)

  test "reading city database" do
    assert "GeoIP2-City" == MetadataStorage.get(@db_name_city).database_type
  end

  test "reading country database" do
    assert "GeoIP2-Country" == MetadataStorage.get(@db_name_country).database_type
  end

  test "no entry found" do
    assert nil == Geolix.lookup(@db_name_city,    { 10, 10, 10, 10 })
    assert nil == Geolix.lookup(@db_name_country, { 10, 10, 10, 10 })

    lookup = Geolix.lookup({ 10, 10, 10, 10 })

    assert nil == lookup[@db_name_city]
    assert nil == lookup[@db_name_country]
  end
end
