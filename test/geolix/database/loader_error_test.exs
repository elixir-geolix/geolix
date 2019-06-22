defmodule Geolix.Database.LoaderErrorTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Geolix.Database.Loader
  alias Geolix.TestHelpers.DatabaseSupervisor

  setup do
    databases = Application.get_env(:geolix, :databases, [])

    on_exit(fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
    end)
  end

  test "(re-) loading databases at start logs errors (kept as state)" do
    databases = [
      %{id: :error_missing_adapter},
      %{id: :error_unknown_adapter, adapter: __MODULE__.Missing}
    ]

    log =
      capture_log(fn ->
        :ok = Application.put_env(:geolix, :databases, databases)
        :ok = DatabaseSupervisor.restart()
      end)

    assert log =~ "missing adapter"
    assert log =~ "unknown adapter"

    Enum.each(databases, fn db ->
      id = db[:id]

      assert %{id: ^id, state: {:error, _}} = Loader.get_database(id)

      assert id in Loader.registered_databases()
      refute id in Loader.loaded_databases()
    end)
  end
end
