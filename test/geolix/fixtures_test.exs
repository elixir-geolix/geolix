defmodule Geolix.FixturesTest do
  use ExUnit.Case, async: true

  alias Geolix.MetadataStorage

  test "city database readable" do
    assert "GeoIP2-City" == MetadataStorage.get(:fixture_city).database_type
  end

  test "country database readable" do
    assert "GeoIP2-Country" == MetadataStorage.get(:fixture_country).database_type
  end

  test "domain database readable" do
    assert "GeoIP2-Domain" == MetadataStorage.get(:fixture_domain).database_type
  end
end
