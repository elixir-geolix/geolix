defmodule Geolix.Server.Pool do
  @moduledoc false

  @doc """
  Returns poolboy child specification for supervision tree.
  """
  @spec child_spec :: Supervisor.Spec.spec()
  def child_spec do
    opts = [
      name: {:local, __MODULE__},
      worker_module: Geolix.Server.Worker,
      size: Application.get_env(:geolix, :pool)[:size] || 5,
      max_overflow: Application.get_env(:geolix, :pool)[:max_overflow] || 10
    ]

    :poolboy.child_spec(__MODULE__, opts, [])
  end
end
