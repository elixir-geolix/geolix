defmodule GeolixTest do
  use ExUnit.Case, async: true

  test "set_db valid" do
    Geolix.start_link()

    assert :ok == Geolix.set_db_cities("/tmp")
    assert :ok == Geolix.set_db_countries("/tmp")
  end

  test "set_db not a path" do
    Geolix.start_link()

    assert { :error, _ } = Geolix.set_db(:unused, "i-should-never-exist!")
  end

  test "set_db invalid type" do
    Geolix.start_link()

    assert { :error, _ } = Geolix.set_db(:invalid, ".")
  end
end
