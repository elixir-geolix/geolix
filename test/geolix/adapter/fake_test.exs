defmodule Geolix.Adapter.FakeTest do
  use ExUnit.Case, async: true

  alias Geolix.Adapter.Fake

  @base_spec %{ id: :fake, adapter: Fake, data: %{} }
  @test_ip4  { 8, 8, 8, 8 }
  @test_ip6  { 0, 0, 0, 0, 0, 65535, 2056, 2056 }


  test "empty data returns nil" do
    Geolix.load_database(@base_spec)

    assert nil == Geolix.lookup(@test_ip4, where: :fake)
    assert nil == Geolix.lookup(@test_ip6, where: :fake)
  end

  test "pre-filled database lookup" do
    term = :fake_adapter_data_term
    data =
      %{}
      |> Map.put(@test_ip4, term)
      |> Map.put(@test_ip6, term)

    Geolix.load_database(%{ @base_spec | data: data })

    assert term == Geolix.lookup(@test_ip4, where: :fake)
    assert term == Geolix.lookup(@test_ip6, where: :fake)
  end
end
