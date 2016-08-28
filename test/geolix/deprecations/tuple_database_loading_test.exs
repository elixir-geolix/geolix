defmodule Geolix.Deprecations.TupleDatabaseLoadingTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "{ which, filename }" do
    stderr = capture_io :stderr, fn ->
      Geolix.set_database(:ignore, "ignore")
    end

    assert String.contains?(stderr, "deprecated")
  end
end
