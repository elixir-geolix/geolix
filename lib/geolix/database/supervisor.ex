defmodule Geolix.Database.Supervisor do
  @moduledoc false

  use Supervisor

  alias Geolix.Database.Loader

  @doc false
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc false
  def init(_default) do
    databases = fetch_databases()
    children = [worker(Loader, [databases]) | workers(databases)]

    supervise(children, strategy: :one_for_all)
  end

  @doc """
  Starts the worker processes of a database if not already under supervision.
  """
  @spec start_database(map) :: :ok
  def start_database(database) do
    database
    |> database_workers()
    |> Enum.each(&Supervisor.start_child(__MODULE__, &1))
  end

  defp database_workers(%{adapter: adapter} = database) do
    case function_exported?(adapter, :database_workers, 1) do
      true -> adapter.database_workers(database)
      false -> []
    end
  end

  defp database_workers(_), do: []

  defp fetch_databases do
    :geolix
    |> Application.get_env(:databases, [])
    |> Enum.map(&preconfigure_database/1)
  end

  defp preconfigure_database(%{init: {mod, fun, extra_args}} = config) do
    apply(mod, fun, [config | extra_args])
  end

  defp preconfigure_database(%{init: {mod, fun}} = config) do
    apply(mod, fun, [config])
  end

  defp preconfigure_database(config), do: config

  defp workers(databases) do
    databases
    |> Enum.flat_map(&database_workers/1)
    |> Enum.uniq_by(fn {id, _, _, _, _, _} -> id end)
  end
end
