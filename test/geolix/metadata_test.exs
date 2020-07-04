defmodule Geolix.MetadataTest do
  use ExUnit.Case, async: true

  alias Geolix.Adapter.Fake

  test "database metadata" do
    db_first = %{id: :test_metadata_first, adapter: Fake, data: %{}}
    db_second = %{id: :test_metadata_second, adapter: Fake, data: %{}}

    :ok = Geolix.load_database(db_first)
    :ok = Geolix.load_database(db_second)

    assert %{load_epoch: _} = Geolix.metadata(where: :test_metadata_first)
    assert %{load_epoch: _} = Geolix.metadata(where: :test_metadata_second)

    assert %{
             test_metadata_first: %{load_epoch: _},
             test_metadata_second: %{load_epoch: _}
           } = Geolix.metadata()

    Geolix.unload_database(db_first)
    Geolix.unload_database(db_second)
  end
end
