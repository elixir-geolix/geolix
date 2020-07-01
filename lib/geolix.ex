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

  There are some options you can pass to `Geolix.lookup/2` to modify the lookup
  behaviour:

  - `:where` - Lookup information in a single registered database

  The adapter used can require and/or understand additional options. To
  accommodate this the options are passed unmodified to the adapter's on lookup
  function.
  """

  alias Geolix.Database.Loader

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
    case opts[:where] do
      nil -> lookup_all(ip, opts)
      where -> lookup_single(ip, opts, where)
    end
  end

  @doc """
  Fetch metadata from one or multiple databases.
  """
  @spec metadata(opts :: Keyword.t()) :: map | nil
  def metadata(opts \\ []) do
    case opts[:where] do
      nil -> metadata_all()
      where -> metadata_single(where)
    end
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

  defp lookup_all(ip, opts) do
    lookup_all(ip, opts, Loader.loaded_databases())
  end

  defp lookup_all(_, _, []), do: %{}

  defp lookup_all(ip, opts, databases) do
    databases
    |> Task.async_stream(
      fn database ->
        {database, lookup_single(ip, opts, database)}
      end,
      ordered: false
    )
    |> Enum.into(%{}, fn {:ok, result} -> result end)
  end

  defp lookup_single(ip, opts, where) do
    case Loader.get_database(where) do
      nil -> nil
      %{adapter: adapter} = database -> adapter.lookup(ip, opts, database)
    end
  end

  defp metadata_all do
    metadata_all(Loader.loaded_databases())
  end

  defp metadata_all(databases) do
    databases
    |> Task.async_stream(
      fn database ->
        {database, metadata_single(database)}
      end,
      ordered: false
    )
    |> Enum.into(%{}, fn {:ok, result} -> result end)
  end

  defp metadata_single(where) do
    with %{adapter: adapter} = database <- Loader.get_database(where),
         true <- function_exported?(adapter, :metadata, 1) do
      adapter.metadata(database)
    else
      _ -> nil
    end
  end
end
