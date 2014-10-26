defmodule Geolix.FixturesTest do
  use ExUnit.Case, async: true

  test "fixtures readable" do
    fixtures = [
      { :fixture_city, "GeoIP2-City" },
      { :fixture_country, "GeoIP2-Country" },
      { :fixture_domain, "GeoIP2-Domain" }
    ]

    Enum.each(
      fixtures,
      fn ({ name, type }) ->
        assert type == Geolix.MetadataStorage.get(name, :database_type)
      end
    )
  end
end
