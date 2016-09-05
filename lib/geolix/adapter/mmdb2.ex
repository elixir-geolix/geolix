defmodule Geolix.Adapter.MMDB2 do
  @moduledoc """
  Adapter for Geolix to work with MMDB2 databases.
  """

  alias Geolix.Adapter.MMDB2.Database
  alias Geolix.Adapter.MMDB2.Loader

  @behaviour Geolix.Adapter

  defdelegate load_database(database), to: Loader

  defdelegate lookup(ip, opts), to: Database
end
