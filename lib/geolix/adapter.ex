defmodule Geolix.Adapter do
  @moduledoc """
  Adapter behaviour module.
  """

  @optional_callbacks [
    database_workers: 0,
    load_database: 1,
    load_database: 2,
    unload_database: 1
  ]

  @doc """
  Returns the children to be supervised by `Geolix.Database.Supervisor`.

  If no automatic supervision should take place or it is intended to use a
  adapter specific supervisor (e.g. using the application config) this callback
  should be either unimplemented or return an empty list.
  """
  @callback database_workers() :: list

  @doc """
  Loads a given database into Geolix.

  Requires at least the fields `:id` and `:adapter`. Any other required
  fields depend on the adapter's requirements.
  """
  @callback load_database(map) :: :ok | {:error, term}

  @doc """
  Loads a given database into Geolix with a specific synchronization style.

  Allowed `sync_type` values:

  - `:sync`
  - `:async`

  When called with `:async` the adapter may return an additional `:delayed`
  response to announce a background loading process. The individual behaviour
  is defined by the adapter and may ignore the `:async` request.

  If this callback is not implemented then `load_database/1` will be tried.
  """
  @callback load_database(map, atom) :: :ok | :delayed | {:error, term}

  @doc """
  Unloads a given database from Geolix.

  Receives the configuration used when initially loading the database.
  """
  @callback unload_database(map) :: :ok

  @doc """
  Looks up IP information.

  The passed `opts` are expected to contain a key `:where` to define
  which database should be queried. If that key is not set then `nil`
  should be returned instead.
  """
  @callback lookup(ip :: tuple, opts :: Keyword.t()) :: map | nil
end
