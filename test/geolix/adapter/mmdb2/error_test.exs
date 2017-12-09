defmodule Geolix.Adapter.MMDB2.ErrorTest do
  use ExUnit.Case, async: true

  test "broken pointers" do
    assert nil == Geolix.lookup({1, 1, 1, 32}, where: :fixture_broken_pointers)
  end

  test "no ipv4 search tree" do
    assert nil == Geolix.lookup({1, 1, 1, 3}, where: :fixture_no_ipv4_search_tree)
  end
end
