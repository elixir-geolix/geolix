defmodule Geolix.Database.Supervisor do
  @moduledoc """
  Supervisor for database processes (storage + loader).
  """

  use Supervisor

  alias Geolix.Adapter.MMDB2.Storage
  alias Geolix.Database.Loader


  @doc """
  Starts the database supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default, [ name: __MODULE__ ])
  end

  @doc false
  def init(_default) do
    databases = Application.get_env(:geolix, :databases, [])
    children  = [ worker(Loader, [ databases ]) | workers(databases) ]

    supervise(children, strategy: :one_for_all)
  end


  @doc """
  Starts the worker processes of an adapter if not already under supervision.
  """
  @spec start_adapter(Module.t) :: :ok
  def start_adapter(adapter) do
    adapter
    |> database_workers()
    |> Enum.each(&( Supervisor.start_child(__MODULE__, &1) ))
  end


  defp database_workers(Geolix.Adapter.MMDB2) do
    [
      worker(Storage.Data, []),
      worker(Storage.Metadata, []),
      worker(Storage.Tree, [])
    ]
  end

  defp workers(databases) do
    databases
    |> Enum.map(&( Map.get(&1, :adapter, nil) ))
    |> Enum.uniq()
    |> Enum.reject(&( &1 == nil ))
    |> Enum.flat_map(&database_workers/1)
  end
end
