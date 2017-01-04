defmodule Geolix.Adapter.MMDB2.ResultTest do
  use ExUnit.Case, async: true

  alias Geolix.Result

  defp result_for(type), do: Result.to_struct(type, %{}, nil).__struct__

  test "unknown type is unmodified" do
    data = %{ foo: :bar }

    assert data == Result.to_struct("invalid-type", data, nil)
  end

  test "type to struct mapping" do
    assert Result.City == result_for("GeoIP2-City")
    assert Result.City == result_for("GeoIP2-Precision-City")
    assert Result.City == result_for("GeoLite2-City")
    assert Result.Country == result_for("GeoIP2-Country")
    assert Result.Country == result_for("GeoLite2-Country")
  end

  test "type to flat struct mapping" do
    assert Result.AnonymousIP == result_for("GeoIP2-Anonymous-IP")
    assert Result.ConnectionType == result_for("GeoIP2-Connection-Type")
    assert Result.Domain == result_for("GeoIP2-Domain")
    assert Result.ISP == result_for("GeoIP2-ISP")
    assert Result.ISP == result_for("GeoIP2-Precision-ISP")
  end
end
