defmodule Geolix.Database.SupervisorTest do
  use ExUnit.Case, async: false

  alias Geolix.Adapter.Fake
  alias Geolix.Database.Supervisor, as: DatabaseSupervisor


  @ip        { 55, 55, 55, 55 }
  @result    :fake_result
  @reload_id :test_reload
  @reload_db %{
    id:      @reload_id,
    adapter: Fake,
    data:    Map.put(%{}, @ip, @result)
  }

  setup do
    databases = Application.get_env(:geolix, :databases)

    :ok = Application.put_env(:geolix, :databases, [ @reload_db ])
    :ok = restart_supervisor()

    on_exit fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
      :ok = restart_supervisor()
    end
  end

  defp restart_supervisor() do
    true =
      DatabaseSupervisor
      |> Process.whereis()
      |> Process.exit(:kill)

    :ok = :timer.sleep(100)
    _   = Application.ensure_all_started(:geolix)
    :ok = Geolix.reload_databases()
    :ok = :timer.sleep(100)
    :ok
  end


  test "reload databases on supervisor restart" do
    assert @result == Geolix.lookup(@ip, where: @reload_id)

    # break data
    Fake.Storage.set(@reload_id, %{})

    assert nil == Geolix.lookup(@ip, where: @reload_id)

    # reload to fix lookup
    :ok = Geolix.reload_databases()
    :ok = :timer.sleep(100)

    assert @result == Geolix.lookup(@ip, where: @reload_id)
  end
end
