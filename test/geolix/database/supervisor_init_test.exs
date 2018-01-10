defmodule Geolix.Database.SupervisorInitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  defmodule Initializer do
    def adapter(%{init: {__MODULE__, :adapter}}) do
      %{
        id: :per_database_init,
        adapter: Geolix.Adapter.Fake,
        data: Map.put(%{}, {1, 2, 3, 4}, :per_database_init_result)
      }
    end
  end

  setup do
    databases = Application.get_env(:geolix, :databases)
    :ok = Application.put_env(:geolix, :databases, [%{init: {Initializer, :adapter}}])

    on_exit(fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
    end)
  end

  test "per-database init function called upon supervisor (re-) start" do
    capture_log(fn ->
      Supervisor.stop(Geolix.Supervisor, :normal)

      :ok = :timer.sleep(100)
      _ = Application.ensure_all_started(:geolix)
      :ok = :timer.sleep(100)

      assert :per_database_init_result == Geolix.lookup({1, 2, 3, 4}, where: :per_database_init)
    end)
  end
end
