defmodule Geolix.Result.DomainTest do
  use ExUnit.Case, async: false

  alias Geolix.Result.Domain

  test "result type" do
    assert %Domain{} = Geolix.lookup("1.2.0.0", where: :fixture_domain)
  end

  test "domain" do
    ip       = { 1, 2, 0, 0 }
    result   = Geolix.lookup(ip, where: :fixture_domain)
    expected = %Domain{ domain:     "maxmind.com",
                        ip_address: ip }

    assert result == expected
  end
end
