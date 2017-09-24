defmodule Geolix.Adapter.MMDB2.Result.CountryTest do
  use ExUnit.Case, async: true

  alias Geolix.Result.Country


  test "result type" do
    assert %Country{} = Geolix.lookup("2.125.160.216", where: :fixture_country)
  end

  test "locale result" do
    result = Geolix.lookup("202.196.224.0", [ locale: :fr, where: :fixture_country ])

    assert result.continent.name == result.continent.names[:fr]
    assert result.country.name == result.country.names[:fr]
    assert result.registered_country.name == result.registered_country.names[:fr]
    assert result.represented_country.name == result.represented_country.names[:fr]
  end

  test "locale result (default :en)" do
    result = Geolix.lookup("202.196.224.0", [ where: :fixture_country ])

    assert result.continent.name == result.continent.names[:en]
    assert result.country.name == result.country.names[:en]
  end

  test "ipv6 lookup" do
    ip                  = "2001:218::"
    { :ok, ip_address } = ip |> String.to_charlist() |> :inet.parse_address()

    result = Geolix.lookup(ip, where: :fixture_country)

    assert result.traits.ip_address == ip_address

    assert "Asia" == result.continent.names[:en]
    assert "Japan" == result.country.names[:en]
    assert "Japan" == result.registered_country.names[:en]
  end

  test "regular country" do
    ip     = { 216, 160, 83, 56 }
    result = Geolix.lookup(ip, where: :fixture_country)

    assert result.traits.ip_address == ip

    assert "NA" == result.continent.code
    assert 6255149 == result.continent.geoname_id
    assert "Северная Америка" == result.continent.names[:ru]

    assert 6252001 == result.country.geoname_id
    assert "US" == result.country.iso_code
    assert "アメリカ合衆国" == result.country.names[:ja]

    assert 2635167 == result.registered_country.geoname_id
    assert "GB" == result.registered_country.iso_code
    assert "Vereinigtes Königreich" == result.registered_country.names[:de]
  end

  test "represented country" do
    ip     = { 202, 196, 224, 0 }
    result = Geolix.lookup(ip, where: :fixture_country)

    assert result.traits.ip_address == ip

    assert "AS" == result.continent.code
    assert 6255147 == result.continent.geoname_id
    assert "Asie" == result.continent.names[:fr]

    assert 1694008 == result.country.geoname_id
    assert "PH" == result.country.iso_code
    assert "Filipinas" == result.country.names[:"pt-BR"]

    assert result.registered_country == result.country

    assert 6252001 == result.represented_country.geoname_id
    assert "US" == result.represented_country.iso_code
    assert "Estados Unidos" == result.represented_country.names[:es]
    assert "military" == result.represented_country.type
  end

  test "with traits" do
    ip     = { 67, 43, 156, 0 }
    result = Geolix.lookup(ip, where: :fixture_country)

    assert result.traits.ip_address == ip
    assert result.traits.is_anonymous_proxy == true
  end
end
