defmodule Geolix.Adapter.MMDB2 do
  @moduledoc """
  Adapter for Geolix to work with MMDB2 databases.
  """

  alias Geolix.Adapter.MMDB2.Database
  alias Geolix.Adapter.MMDB2.Loader
  alias Geolix.Adapter.MMDB2.Storage

  @behaviour Geolix.Adapter

  def database_workers() do
    import Supervisor.Spec

    [
      worker(Storage.Data, []),
      worker(Storage.Metadata, []),
      worker(Storage.Tree, [])
    ]
  end

  defdelegate load_database(database), to: Loader

  defdelegate lookup(ip, opts), to: Database
end
