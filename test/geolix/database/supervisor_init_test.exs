defmodule Geolix.Database.SupervisorInitTest do
  use ExUnit.Case, async: false

  alias Geolix.TestHelpers.DatabaseSupervisor

  defmodule Initializer do
    def adapter(database), do: adapter(database, %{test: :empty})

    def adapter(_config, result) do
      %{
        id: :per_database_init,
        adapter: Geolix.Adapter.Fake,
        data: Map.put(%{}, {1, 2, 3, 4}, result)
      }
    end
  end

  setup_all do
    databases = Application.get_env(:geolix, :databases, [])

    on_exit(fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
    end)
  end

  test "per-database init {mod, fun} called upon supervisor (re-) start" do
    databases = [%{init: {Initializer, :adapter}}]

    :ok = Application.put_env(:geolix, :databases, databases)
    :ok = DatabaseSupervisor.restart()

    assert %{test: :empty} == Geolix.lookup({1, 2, 3, 4}, where: :per_database_init)
  end

  test "per-database init {mod, fun, args} called upon supervisor (re-) start" do
    result = %{test: :result}
    databases = [%{init: {Initializer, :adapter, [result]}}]

    :ok = Application.put_env(:geolix, :databases, databases)
    :ok = DatabaseSupervisor.restart()

    assert result == Geolix.lookup({1, 2, 3, 4}, where: :per_database_init)
  end
end
