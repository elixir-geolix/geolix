defmodule Geolix.DatabaseTest do
  use ExUnit.Case, async: true

  alias Geolix.Database

  test "error if database contains no metadata" do
    { fixture, filename, _ } =
         Mix.Tasks.Geolix.Fixtures.list()
      |> Enum.find(fn ({ fixture, _, _ }) -> :fixture_broken_pointers == fixture end)

    path = Path.join([ __DIR__, "../fixtures", filename ]) |> Path.expand()

    assert { :error, :no_metadata } == Database.read_database(fixture, path)
  end
end
