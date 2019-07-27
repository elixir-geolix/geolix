defmodule Geolix.MetadataTest do
  use ExUnit.Case, async: true

  @db_first %{
    id: :test_metadata_first,
    adapter: Geolix.Adapter.Fake,
    data: %{}
  }

  @db_second %{
    id: :test_metadata_second,
    adapter: Geolix.Adapter.Fake,
    data: %{}
  }

  setup do
    :ok = Geolix.load_database(@db_first)
    :ok = Geolix.load_database(@db_second)
    :ok
  end

  test "single database metadata" do
    assert %{load_epoch: _} = Geolix.metadata(where: :test_metadata_first)
    assert %{load_epoch: _} = Geolix.metadata(where: :test_metadata_second)
  end

  test "multi database metadata" do
    assert %{
             test_metadata_first: %{load_epoch: _},
             test_metadata_second: %{load_epoch: _}
           } = Geolix.metadata()
  end
end
