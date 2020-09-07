defmodule Geolix.Adapter do
  @moduledoc """
  Adapter behaviour module.
  """

  @optional_callbacks [
    database_workers: 1,
    load_database: 1,
    metadata: 1,
    unload_database: 1
  ]

  @doc """
  Returns the adapter processes to be supervised.

  If no automatic supervision should take place or it is intended to use an
  adapter specific supervisor (e.g. using the application config) this callback
  should be either unimplemented or return an empty list.
  """
  @callback database_workers(database :: Geolix.database()) :: [
              :supervisor.child_spec() | {module, term} | module
            ]

  @doc """
  Loads a given database into Geolix.

  Requires at least the fields `:id` and `:adapter`. Any other required
  fields depend on the adapter's requirements.
  """
  @callback load_database(database :: Geolix.database()) :: :ok | :delayed | {:error, term}

  @doc """
  Looks up IP information.
  """
  @callback lookup(ip :: :inet.ip_address(), opts :: Keyword.t(), database :: Geolix.database()) ::
              map | nil

  @doc """
  Returns metadata information for a database if available.
  """
  @callback metadata(database :: Geolix.database()) :: map | nil

  @doc """
  Unloads a given database from Geolix.
  """
  @callback unload_database(database :: Geolix.database()) :: :ok
end
