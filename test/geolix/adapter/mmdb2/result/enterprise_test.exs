defmodule Geolix.Adapter.MMDB2.Result.EnterpriseTest do
  use ExUnit.Case, async: true

  alias Geolix.Record.EnterpriseSubdivision
  alias Geolix.Result.Enterprise

  test "result type" do
    result = Geolix.lookup("74.209.24.0", where: :fixture_enterprise)

    assert %Enterprise{}            = result
    assert %EnterpriseSubdivision{} = result.subdivisions |> hd()
  end

  test "locale result" do
    result      = Geolix.lookup("74.209.24.0", [ locale: :en, where: :fixture_enterprise ])
    subdivision = result.subdivisions |> hd()

    assert result.continent.name == result.continent.names[:en]
    assert result.country.name == result.country.names[:en]
    assert result.registered_country.name == result.registered_country.names[:en]

    assert subdivision.name == subdivision.names[:en]
  end

  test "enterprise result" do
    ip     = { 74, 209, 24, 0 }
    result = Geolix.lookup(ip, where: :fixture_enterprise)

    assert result.traits.ip_address == ip

    assert result.traits.autonomous_system_number == 14671
    assert result.traits.autonomous_system_organization == "FairPoint Communications"
    assert result.traits.connection_type == "Cable/DSL"
    assert result.traits.domain == "frpt.net"
    assert result.traits.is_anonymous_proxy == true
    assert result.traits.is_legitimate_proxy == true
    assert result.traits.is_satellite_provider == true
    assert result.traits.isp == "Fairpoint Communications"
    assert result.traits.organization == "Fairpoint Communications"
    assert result.traits.user_type == "residential"

    assert 5112335 == result.city.geoname_id
    assert 6255149 == result.continent.geoname_id
    assert 6252001 == result.registered_country.geoname_id

    subdivision = result.subdivisions |> hd()

    assert 11 == result.city.confidence
    assert 99 == result.country.confidence
    assert 27 == result.location.accuracy_radius
    assert 11 == result.postal.confidence
    assert 93 == subdivision.confidence
  end
end
