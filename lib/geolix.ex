defmodule Geolix do
  @moduledoc """
  IP location lookup provider.

  ## Usage

  Fetching information for a single IP is done by passing it as a binary or
  tuple to `Geolix.lookup/1`:

      iex> Geolix.lookup("127.0.0.1")
      %{
        city: %{...},
        country: %{...}
      }

  The response will be a map with the `:id` of each configured database as the
  key and the database response as the value.

  If you are only interested in the response of a specific database you can use
  `Geolix.lookup/2`:

      iex> Geolix.lookup({127, 0, 0, 1}, where: :my_database)
      %{...}

  The result structured of each database is specific to the adapter used.

  ### Lookup Options

  There are two options you can pass to `Geolix.lookup/2` to modify the lookup
  behaviour:

  - `:timeout` - GenServer call timeout for the lookup. Defaults to `5_000`.
  - `:where` - Lookup information in a single registered database

  The adapter used can require and/or understand additional options. To
  accommodate this the options are passed unmodified to the adapter's on lookup
  function.
  """

  alias Geolix.Database.Loader
  alias Geolix.Server.Pool

  @doc """
  Looks up IP information.
  """
  @spec lookup(ip :: :inet.ip_address() | binary, opts :: Keyword.t()) :: map | nil
  def lookup(ip, opts \\ [])

  def lookup(ip, opts) when is_binary(ip) do
    case :inet.parse_address(Kernel.to_charlist(ip)) do
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
