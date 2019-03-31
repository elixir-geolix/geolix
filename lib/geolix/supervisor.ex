defmodule Geolix.Supervisor do
  @moduledoc """
  Geolix Supervisor.
  """

  use Supervisor

  alias Geolix.Database
  alias Geolix.Server.Pool

  @doc false
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc false
  def init(_default) do
    :ok =
      case Application.get_env(:geolix, :init) do
        {mod, fun, args} -> apply(mod, fun, args)
        {mod, fun} -> apply(mod, fun, [])
        nil -> :ok
      end

    children = [
      Pool.child_spec(),
      supervisor(Database.Supervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
