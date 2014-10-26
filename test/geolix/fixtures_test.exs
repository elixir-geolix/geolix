defmodule Geolix.FixturesTest do
  use ExUnit.Case, async: true

  alias Geolix.Storage.Metadata

  test "fixtures readable" do
    fixtures = [
      { :fixture_city, "GeoIP2-City" },
      { :fixture_country, "GeoIP2-Country" },
      { :fixture_domain, "GeoIP2-Domain" }
    ]

    Enum.each(
      fixtures,
      fn ({ name, type }) ->
        assert type == Metadata.get(name, :database_type)
      end
    )
  end
end
