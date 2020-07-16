defmodule Geolix.Database.SupervisorTest do
  use ExUnit.Case, async: false

  alias Geolix.Adapter.Fake
  alias Geolix.Database.Loader

  defmodule Initializer do
    def adapter(database), do: adapter(database, %{test: :empty})

    def adapter(%{notify: pid}, result) do
      send(pid, result)

      %{
        id: :per_database_init,
        adapter: Fake,
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
    databases = [%{init: {Initializer, :adapter}, notify: self()}]

    :ok = Application.put_env(:geolix, :databases, databases)
    :ok = Supervisor.terminate_child(Geolix.Supervisor, Loader)
    {:ok, _} = Supervisor.restart_child(Geolix.Supervisor, Loader)

    assert_receive %{test: :empty}
  end

  test "per-database init {mod, fun, args} called upon supervisor (re-) start" do
    result = %{test: :result}
    databases = [%{init: {Initializer, :adapter, [result]}, notify: self()}]

    :ok = Application.put_env(:geolix, :databases, databases)
    :ok = Supervisor.terminate_child(Geolix.Supervisor, Loader)
    {:ok, _} = Supervisor.restart_child(Geolix.Supervisor, Loader)

    assert_receive ^result
  end
end
