defmodule Geolix.Adapter.Fake do
  @moduledoc """
  Fake adapter for testing environments.
  """

  alias Geolix.Adapter.Fake.Storage

  @behaviour Geolix.Adapter

  def database_workers() do
    import Supervisor.Spec

    [worker(Storage, [])]
  end

  @doc """
  Implementation of `Geolix.Adapter.load_database/1`.

  Requires the parameter `:data` to be a map with all database entries.

  Each database entry is one entry in the map. The key should be an exact
  IP address in a format returned by `:inet.parse_address/1` while the result
  can be any term.
  """
  def load_database(%{data: data, id: id}), do: Storage.set(id, data)

  def lookup(ip, opts) do
    case opts[:where] do
      nil -> nil
      where -> where |> Storage.get() |> Map.get(ip, nil)
    end
  end
end
