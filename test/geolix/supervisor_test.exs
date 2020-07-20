defmodule Geolix.SupervisorTest do
  use ExUnit.Case, async: true

  defmodule Initializer do
    use Agent

    def start_link(_), do: Agent.start_link(fn -> nil end, name: __MODULE__)

    def call_init, do: call_init(:ok_empty)
    def call_init(result), do: Agent.update(__MODULE__, fn _ -> result end)

    def get_init, do: Agent.get(__MODULE__, & &1)
  end

  test "init {mod, fun} called upon supervisor (re-) start" do
    {:ok, _} = start_supervised(Initializer)

    :ok = Application.put_env(:geolix, :init, {Initializer, :call_init})
    _ = Geolix.Supervisor.init([])

    assert :ok_empty = Initializer.get_init()
  after
    :ok = Application.delete_env(:geolix, :init)
  end

  test "init {mod, fun, args} called upon supervisor (re-) start" do
    {:ok, _} = start_supervised(Initializer)

    :ok = Application.put_env(:geolix, :init, {Initializer, :call_init, [:ok_passed]})
    _ = Geolix.Supervisor.init([])

    assert :ok_passed = Initializer.get_init()
  after
    :ok = Application.delete_env(:geolix, :init)
  end
end
