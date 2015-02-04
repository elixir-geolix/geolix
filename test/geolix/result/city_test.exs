defmodule Geolix.Result.CityTest do
  use ExUnit.Case, async: false

  alias Geolix.Record.Subdivision
  alias Geolix.Result.City

  test "result type" do
    result = Geolix.lookup("2.125.160.216", :fixture_city)

    assert %City{}        = result
    assert %Subdivision{} = result.subdivisions |> hd()
  end

  test "subdivisions: single" do
    ip     = { 81, 2, 69, 144 }
    result = Geolix.lookup(ip, :fixture_city)

    assert result.traits.ip_address == ip

    assert "Londres" == result.city.names[:fr]

    [ sub ] = result.subdivisions

    assert 6269131 == sub.geoname_id
    assert "ENG" == sub.iso_code
    assert "Inglaterra" == sub.names[:"pt-BR"]
  end

  test "subdivisions: multiple" do
    ip     = { 2, 125, 160, 216 }
    result = Geolix.lookup(ip, :fixture_city)

    assert result.traits.ip_address == ip

    assert "Boxford" == result.city.names[:en]

    [ sub_1, sub_2 ] = result.subdivisions

    assert 6269131 == sub_1.geoname_id
    assert 3333217 == sub_2.geoname_id
  end
end
