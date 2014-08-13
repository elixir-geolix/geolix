defmodule GeolixTest do
  use ExUnit.Case, async: false

  test "set_db valid" do
    assert :ok == Geolix.set_db_cities("/tmp")
    assert :ok == Geolix.set_db_countries("/tmp")
  end

  test "set_db not a path" do
    assert { :error, _ } = Geolix.set_db(:unused, "i-should-never-exist!")
  end

  test "set_db invalid type" do
    assert { :error, _ } = Geolix.set_db(:invalid, ".")
  end
end
