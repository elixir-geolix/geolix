defmodule Geolix.Database.SupervisorInitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Geolix.TestHelpers.DatabaseSupervisor

  defmodule Initializer do
    def adapter(database), do: adapter(database, :ok_empty)

    def adapter(_config, result) do
      %{
        id: :per_database_init,
        adapter: Geolix.Adapter.Fake,
        data: Map.put(%{}, {1, 2, 3, 4}, result)
      }
    end
  end

  setup_all do
    databases = Application.get_env(:geolix, :databases)

    on_exit(fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
    end)
  end

  test "per-database init {mod, fun} called upon supervisor (re-) start" do
    capture_log(fn ->
      databases = [%{init: {Initializer, :adapter}}]

      :ok = Application.put_env(:geolix, :databases, databases)
      :ok = DatabaseSupervisor.restart()

      assert :ok_empty == Geolix.lookup({1, 2, 3, 4}, where: :per_database_init)
    end)
  end

  test "per-database init {mod, fun, args} called upon supervisor (re-) start" do
    capture_log(fn ->
      databases = [%{init: {Initializer, :adapter, [:ok_passed]}}]

      :ok = Application.put_env(:geolix, :databases, databases)
      :ok = DatabaseSupervisor.restart()

      assert :ok_passed == Geolix.lookup({1, 2, 3, 4}, where: :per_database_init)
    end)
  end
end
