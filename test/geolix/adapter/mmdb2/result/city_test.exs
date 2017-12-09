defmodule Geolix.Adapter.MMDB2.Result.CityTest do
  use ExUnit.Case, async: true

  alias Geolix.Record.Subdivision
  alias Geolix.Result.City

  test "result type" do
    result = Geolix.lookup("2.125.160.216", where: :fixture_city)

    assert %City{} = result
    assert %Subdivision{} = result.subdivisions |> hd()
  end

  test "locale result" do
    result = Geolix.lookup("2.125.160.216", locale: :fr, where: :fixture_city)
    subdivision = result.subdivisions |> hd()

    assert result.continent.name == result.continent.names[:fr]
    assert result.country.name == result.country.names[:fr]
    assert result.registered_country.name == result.registered_country.names[:fr]

    assert subdivision.name == subdivision.names[:fr]
  end

  test "locale result (default :en)" do
    result = Geolix.lookup("2.125.160.216", where: :fixture_city)

    assert result.continent.name == result.continent.names[:en]
    assert result.country.name == result.country.names[:en]
  end

  test "ipv6 lookup" do
    ip = "2001:298::"
    {:ok, ip_address} = ip |> String.to_charlist() |> :inet.parse_address()

    result = Geolix.lookup(ip, where: :fixture_city)

    assert result.traits.ip_address == ip_address

    assert "Asia" == result.continent.names[:en]
    assert "Japan" == result.country.names[:en]
    assert "Japan" == result.registered_country.names[:en]
    assert "Asia/Tokyo" == result.location.time_zone
  end

  test "regular city" do
    ip = {175, 16, 199, 0}
    result = Geolix.lookup(ip, where: :fixture_city)

    assert result.traits.ip_address == ip

    assert "Chángchūn" == result.city.names[:de]
    assert "Ásia" == result.continent.names[:"pt-BR"]
    assert "China" == result.country.names[:es]

    assert 100 == result.location.accuracy_radius
    assert 43.88 == result.location.latitude
    assert 125.3228 == result.location.longitude

    assert "CN" == result.registered_country.iso_code

    subdivision = result.subdivisions |> hd()

    assert "22" == subdivision.iso_code
    assert "Jilin Sheng" == subdivision.names[:en]
  end

  test "represented country" do
    ip = {202, 196, 224, 0}
    result = Geolix.lookup(ip, where: :fixture_city)

    assert result.traits.ip_address == ip

    assert "Philippines" == result.country.names[:en]
    assert "Philippines" == result.registered_country.names[:en]
    assert "United States" == result.represented_country.names[:en]

    assert "military" == result.represented_country.type
  end

  test "subdivisions: single" do
    ip = {81, 2, 69, 144}
    result = Geolix.lookup(ip, where: :fixture_city)

    assert result.traits.ip_address == ip

    assert "Londres" == result.city.names[:fr]

    [sub] = result.subdivisions

    assert 6_269_131 == sub.geoname_id
    assert "ENG" == sub.iso_code
    assert "Inglaterra" == sub.names[:"pt-BR"]
  end

  test "subdivisions: multiple" do
    ip = {2, 125, 160, 216}
    result = Geolix.lookup(ip, where: :fixture_city)

    assert result.traits.ip_address == ip

    assert "Boxford" == result.city.names[:en]

    [sub_1, sub_2] = result.subdivisions

    assert 6_269_131 == sub_1.geoname_id
    assert 3_333_217 == sub_2.geoname_id
  end

  test "with traits" do
    ip = {67, 43, 156, 0}
    result = Geolix.lookup(ip, where: :fixture_city)

    assert result.traits.ip_address == ip
    assert result.traits.is_anonymous_proxy == true
  end
end
