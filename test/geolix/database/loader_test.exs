defmodule Geolix.Database.LoaderTest do
  use ExUnit.Case, async: true

  alias Geolix.Database.Loader


  test "fetching registered database information" do
    id       = :fixture_city
    database = GenServer.call(Loader, { :get_database, id })

    assert %{ id: ^id, state: :loaded } = database
  end

  test "fetching un-registered database information" do
    refute GenServer.call(Loader, { :get_database, :database_not_loaded })
  end
end
