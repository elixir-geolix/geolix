defmodule Geolix.Database.Supervisor do
  @moduledoc """
  Supervisor for database processes (storage + loader).
  """

  use Supervisor

  @doc """
  Starts the database loader.
  """
  @spec start_link(term) :: Supervisor.on_start
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default)
  end

  @doc false
  def init(_default) do
    databases = Application.get_env(:geolix, :databases, [])
    children  = [
      worker(Geolix.Storage.Data, []),
      worker(Geolix.Storage.Metadata, []),
      worker(Geolix.Storage.Tree, []),

      worker(Geolix.Database.Loader, [ databases ])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
