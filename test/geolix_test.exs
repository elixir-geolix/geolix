defmodule GeolixTest do
  use ExUnit.Case, async: false

  test "set_db not a file" do
    assert { :error, _ } = Geolix.set_db_cities("i-should-never-exist!")
    assert { :error, _ } = Geolix.set_db_countries("i-should-never-exist!")
  end

  test "set_db invalid type" do
    assert { :error, _ } = Geolix.set_db(:invalid, ".")
  end

  test "lookup without db" do
    assert nil == Geolix.city({ 127, 0, 0, 1 })
    assert nil == Geolix.country({ 127, 0, 0, 1 })

    assert %{ city: nil, country: nil } == Geolix.lookup({ 127, 0, 0, 1 })
  end
end
