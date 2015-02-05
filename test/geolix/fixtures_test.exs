defmodule Geolix.FixturesTest do
  use ExUnit.Case, async: true

  alias Geolix.Storage.Metadata

  test "fixtures readable" do
    fixtures = [
      { :fixture_city, "GeoIP2-City" },
      { :fixture_connection, "GeoIP2-Connection-Type" },
      { :fixture_country, "GeoIP2-Country" },
      { :fixture_domain, "GeoIP2-Domain" },
      { :fixture_precision, "GeoIP2-Precision-City" },

      { :fixture_ipv4_24, "Test" },
      { :fixture_ipv4_28, "Test" },
      { :fixture_ipv4_32, "Test" },
      { :fixture_ipv6_24, "Test" },
      { :fixture_ipv6_28, "Test" },
      { :fixture_ipv6_32, "Test" }
    ]

    Enum.each(
      fixtures,
      fn ({ name, type }) ->
        assert type == Metadata.get(name, :database_type)
      end
    )
  end
end
