defmodule GeolixTest do
  use ExUnit.Case, async: false

  test "set_db not a file" do
    assert { :error, _ } = Geolix.set_database(:database, "invalid")
  end

  test "lookup without db" do
    assert nil == Geolix.lookup(:database, { 127, 0, 0, 1 })
  end
end
