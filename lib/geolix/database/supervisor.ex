defmodule Geolix.Database.Supervisor do
  @moduledoc false

  use DynamicSupervisor

  @doc false
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc false
  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)

  @doc """
  Starts the worker processes of a database if not already under supervision.
  """
  @spec start_database(Geolix.database()) :: :ok
  def start_database(database) do
    database
    |> database_workers()
    |> Enum.each(&DynamicSupervisor.start_child(__MODULE__, &1))
  end

  defp database_workers(%{adapter: adapter} = database) do
    if function_exported?(adapter, :database_workers, 1) do
      adapter.database_workers(database)
    else
      []
    end
  end

  defp database_workers(_), do: []
end
