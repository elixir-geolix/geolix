defmodule Geolix.DatabaseTest do
  use ExUnit.Case, async: true

  alias Geolix.Database

  test "error if database contains no metadata" do
    path = Path.join([ __DIR__, "../fixtures/.gitignore" ]) |> Path.expand()

    assert { :error, :no_metadata } == Database.read_database(:invalid, path)
  end
end
