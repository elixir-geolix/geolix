defmodule Geolix.Result.ISPTest do
  use ExUnit.Case, async: false

  alias Geolix.Result.ISP

  test "result type" do
    assert %ISP{} = Geolix.lookup("1.0.128.0", :fixture_isp)
  end

  test "autonomous system" do
    ip       = { 222, 230, 140, 0 }
    result   = Geolix.lookup(ip, :fixture_isp)
    expected = %ISP{ autonomous_system_number:       2519,
                     autonomous_system_organization: "JPNIC",
                     ip_address:                     ip }

    assert result == expected
  end

  test "complete entry" do
    ip       = { 176, 128, 0, 0 }
    result   = Geolix.lookup(ip, :fixture_isp)
    expected = %ISP{ autonomous_system_number:       12844,
                     autonomous_system_organization: "Bouygues Telecom",
                     ip_address:                     ip,
                     isp:                            "Bouygues Telecom",
                     organization:                   "Bouygues Telecom" }

    assert result == expected
  end

  test "isp + organization" do
    ip       = { 196, 12, 144, 0 }
    result   = Geolix.lookup(ip, :fixture_isp)
    expected = %ISP{ ip_address:   ip,
                     isp:          "Rwandatel, SA",
                     organization: "Wireless Broadband Customer" }

    assert result == expected
  end

  test "missing: autonomous_system_organization" do
    ip       = { 142, 217, 214, 0 }
    result   = Geolix.lookup(ip, :fixture_isp)
    expected = %ISP{ autonomous_system_number: 35911,
                     ip_address:               ip,
                     isp:                      "Telebec",
                     organization:             "LINO Solutions Internet de Télébec" }

    assert result == expected
  end

  test "only: autonomous system number" do
    ip       = { 69, 218, 48, 0 }
    result   = Geolix.lookup(ip, :fixture_isp)
    expected = %ISP{ autonomous_system_number: 7132,
                     ip_address:               ip }

    assert result == expected
  end

  test "only: isp" do
    ip       = { 41, 112, 0, 0 }
    result   = Geolix.lookup(ip, :fixture_isp)
    expected = %ISP{ ip_address: ip,
                     isp:        "MTN SA" }

    assert result == expected
  end

  test "only: organization" do
    ip       = { 32, 64, 159, 0 }
    result   = Geolix.lookup(ip, :fixture_isp)
    expected = %ISP{ ip_address:   ip,
                     organization: "AT&T Wireless" }

    assert result == expected
  end
end
