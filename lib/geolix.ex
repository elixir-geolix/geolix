defmodule Geolix do
  @moduledoc """
  Geolix Application.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    databases = Application.get_env(:geolix, :databases, [])

    options  = [ strategy: :one_for_one, name: Geolix.Supervisor ]
    children = [
      Geolix.Server.Pool.child_spec,

      worker(Geolix.Storage.Data, []),
      worker(Geolix.Storage.Metadata, []),
      worker(Geolix.Storage.Tree, []),

      worker(Geolix.Database.Loader, [ databases ])
    ]

    Supervisor.start_link(children, options)
  end

  @doc """
  Adds a database to lookup data from.
  """
  @spec set_database(atom, String.t) :: :ok | { :error, String.t }
  defdelegate set_database(which, filename), to: Geolix.Database.Loader

  @doc """
  Looks up IP information.
  """
  @spec lookup(ip :: tuple | String.t) :: nil | map
  defdelegate lookup(ip), to: Geolix.Pool

  @doc """
  Looks up IP information.
  """
  @spec lookup(ip :: tuple | String.t, opts  :: Keyword.t) :: nil | map
  defdelegate lookup(ip, opts), to: Geolix.Pool
end
