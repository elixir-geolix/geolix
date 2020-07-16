defmodule Geolix.Database.LoaderErrorTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Geolix.Database.Loader

  defmodule LoaderNotifyAdapter do
    @behaviour Geolix.Adapter

    def load_database(%{notify: pid}) do
      send(pid, :initialized)
      :ok
    end

    def lookup(_, _, _), do: nil
  end

  setup do
    databases = Application.get_env(:geolix, :databases, [])

    on_exit(fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
    end)
  end

  test "(re-) loading databases at start logs errors (kept as state)" do
    databases = [
      %{id: :error_missing_adapter},
      %{id: :error_unknown_adapter, adapter: __MODULE__.Missing},
      %{id: :loader_error_notifier, adapter: LoaderNotifyAdapter, notify: self()}
    ]

    log =
      capture_log(fn ->
        :ok = Application.put_env(:geolix, :databases, databases)
        :ok = Supervisor.terminate_child(Geolix.Supervisor, Loader)
        {:ok, _} = Supervisor.restart_child(Geolix.Supervisor, Loader)

        assert_receive :initialized
      end)

    assert log =~ "missing adapter"
    assert log =~ "unknown adapter"

    Enum.each(databases, fn
      %{id: :loader_error_notifier} ->
        :ok

      %{id: id} ->
        assert %{id: ^id, state: {:error, _}} = Loader.get_database(id)

        assert id in Loader.registered_databases()
        refute id in Loader.loaded_databases()
    end)
  end
end
