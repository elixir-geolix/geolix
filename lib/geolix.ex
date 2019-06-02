defmodule Geolix do
  @moduledoc """
  IP location lookup provider.
  """

  alias Geolix.Database.Loader
  alias Geolix.Server.Pool

  @doc """
  Looks up IP information.
  """
  @spec lookup(ip :: :inet.ip_address() | String.t(), opts :: Keyword.t()) :: map | nil
  def lookup(ip, opts \\ [])

  def lookup(ip, opts) when is_binary(ip) do
    case :inet.parse_address(String.to_charlist(ip)) do
      {:ok, parsed} -> lookup(parsed, opts)
      {:error, _} -> nil
    end
  end

  def lookup(ip, opts) when is_tuple(ip) do
    request = {:lookup, ip, opts}
    timeout = Keyword.get(opts, :timeout, 5000)

    :poolboy.transaction(Pool, &GenServer.call(&1, request, timeout))
  end

  @doc """
  Loads a database according to its specification.

  Requires at least the fields `:id` and `:adapter`. Any other required
  fields depend on the adapter's requirements.
  """
  @spec load_database(map) :: :ok | {:error, term}
  def load_database(database) do
    GenServer.call(Loader, {:load_database, database}, :infinity)
  end

  @doc """
  Reloads all configured databases in the background.
  """
  @spec reload_databases() :: :ok
  def reload_databases, do: GenServer.cast(Loader, :reload_databases)

  @doc """
  Unloads a database.

  This operation is lazy. The database will stay loaded but won't be reloaded
  or used for lookups.
  """
  @spec unload_database(atom) :: :ok
  def unload_database(id), do: GenServer.call(Loader, {:unload_database, id})
end
