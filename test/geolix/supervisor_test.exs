defmodule Geolix.SupervisorTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  defmodule Initializer do
    def start_link, do: Agent.start_link(fn -> nil end, name: __MODULE__)

    def call_init, do: Agent.update(__MODULE__, fn _ -> :ok end)
    def get_init, do: Agent.get(__MODULE__, & &1)
  end

  setup do
    init = Application.get_env(:geolix, :init)
    :ok = Application.put_env(:geolix, :init, {Initializer, :call_init})

    {:ok, _} = Initializer.start_link()

    on_exit(fn ->
      :ok = Application.put_env(:geolix, :init, init)
    end)
  end

  test "init function called upon supervisor (re-) start" do
    capture_log(fn ->
      Supervisor.stop(Geolix.Supervisor, :normal)

      :ok = :timer.sleep(100)
      _ = Application.ensure_all_started(:geolix)
      :ok = :timer.sleep(100)

      assert :ok == Initializer.get_init()
    end)
  end
end
