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
    Supervisor.start_link(__MODULE__, default)
  end

  @doc false
  def init(_default) do
    databases = Application.get_env(:geolix, :databases, [])
    children  = [
      worker(Storage.Data, []),
      worker(Storage.Metadata, []),
      worker(Storage.Tree, []),

      worker(Loader, [ databases ])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
