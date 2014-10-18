defmodule GeolixTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  require Logger

  test "set_db valid but unfound" do
    path = "/tmp"
    log  = capture_io(:user, fn ->
      assert :ok == Geolix.set_db_cities(path)
      assert :ok == Geolix.set_db_countries(path)

      Logger.flush()
    end)

    assert String.contains?(log, path)
    assert String.contains?(log, "GeoLite2-City.mmdb")
    assert String.contains?(log, "GeoLite2-Country.mmdb")
  end

  test "set_db not a path" do
    assert { :error, _ } = Geolix.set_db(:unused, "i-should-never-exist!")
  end

  test "set_db invalid type" do
    assert { :error, _ } = Geolix.set_db(:invalid, ".")
  end
end
