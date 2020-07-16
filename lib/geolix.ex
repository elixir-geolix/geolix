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

  The result will be a map with the `:id` of each configured database as the
  key and the lookup result as the value.

  If you are only interested in the result of a specific database you can use
  `Geolix.lookup/2`:

      iex> Geolix.lookup({127, 0, 0, 1}, where: :my_database)
      %{...}

  The result structure of each database is specific to the adapter used.

  ### Lookup Options

  There are some options you can pass to `Geolix.lookup/2` to modify the lookup
  behaviour:

  - `:where` - Lookup information in a single registered database

  The adapter used can require and/or understand additional options. To
  accommodate this the options are passed unmodified to the adapter's own
  lookup function.

  ## Database Configuration

  To get started you need to define one or more `:databases` to use for
  lookups. Each database definition is a map with at least two fields:

  - `:id` - an identifier for this database, usable to limit lookups to a
    single database if you have defined more than one
  - `:adapter` - the adapter module used to handle lookup requests. See the
    part "Adapters" in for additional information

  Depending on the adapter you may need to provide additional values.

  ### Configuration (static)

  One option for configuration is using a static configuration, i.e. for two
  databases handled by the adapter `MyAdapter`:

      config :geolix,
        databases: [
          %{
            id: :city,
            adapter: MyAdapter,
            source: "/absolute/path/to/city.db"
          },
          %{
            id: :country,
            adapter: MyAdapter,
            source: "/absolute/path/to/country.db"
          }
        ]

  ### Configuration (dynamic)

  If there are any reasons you cannot use a pre-defined configuration you can
  also configure an initializer module to be called before starting the
  top-level suprevisor or alternatively for each individual database.

  This may be the most suitable configuration if you have the database located
  in the `:priv_dir` of your application:

      # {mod, fun}
      config :geolix,
        init: {MyInitModule, :my_init_mf_toplevel}

      config :geolix,
        databases: [
          %{
            id: :dynamic_country,
            adapter: MyAdapter,
            init: {MyInitModule, :my_init_mf_database}
          }
        ]

      # {mod, fun, args}
      config :geolix,
        init: {MyInitModule, :my_init_mfargs_toplevel, [:foo, :bar]}

      config :geolix,
        databases: [
          %{
            id: :dynamic_country,
            adapter: MyAdapter,
            init: {MyInitModule, :my_init_mfargs_database, [:foo, :bar]}
          }
        ]

      # initializer module
      defmodule MyInitModule do
        @spec my_init_mf_toplevel() :: :ok
        def my_init_mf_toplevel(), do: my_init_mfargs_toplevel(:foo, :bar)

        @spec my_init_mfargs_toplevel(atom, atom) :: :ok
        def my_init_mfargs_toplevel(:foo, :bar) do
          priv_dir = Application.app_dir(:my_app, "priv")

          databases = [
            %{
              id: :dynamic_city,
              adapter: MyAdapter,
              source: Path.join([priv_dir, "city.db"])
            }
            | Application.get_env(:geolix, :databases, [])
          ]

          Application.put_env(:geolix, :databases, databases)
        end

        @spec my_init_mf_database(map) :: map
        def my_init_mf_database(database) do
          my_init_mfargs_database(database, :foo, :bar)
        end

        @spec my_init_mfargs_database(map, atom, atom) :: map
        def my_init_mfargs_database(%{id: :dynamic_country} = database, :foo, :bar) do
          priv_dir = Application.app_dir(:my_app, "priv")

          %{database | source: Path.join([priv_dir, "country.db"])}
        end
      end

  Above example illustrates both types of dynamic initialization.

  The top-level initializer is called as defined (`{mod, fun}` or
  `{mod, fun, args}`) and expected to always return `:ok`. At the database
  level the current database configuration is passed as the first parameter
  with additional parameters following. It is expected that this
  function returns the new, complete configuration.

  If you choose to use the dynamic database initialization the only requirement
  for your config file is a plain `%{init: {MyInitModule, :my_init_fun}}` entry.
  Every additional field in the example is only used for illustration and only
  required for the complete return value.

  ### Configuration (runtime)

  If you do not want to use a pre-defined or dynamically initialized
  configuration you can also define and start adapters at runtime:

      iex(1)> Geolix.load_database(%{
      ...(1)>   id: :runtime_city,
      ...(1)>   adapter: MyAdapter,
      ...(1)>   source: "/absolute/path/to/city.db"
      ...(1)> })
      :ok

  Please be aware that these databases will not be reloaded if,
  for any reason, the supervisor/application is restarted.

  Running `load_database/1` on an already configured database (matched by `:id`)
  will reload/replace it without persisting the configuration. On success a
  result of `:ok` will be returned otherwise a tuple in the style of
  `{:error, message}`. The individual errors are defined by the adapter.
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
  @spec unload_database(atom | map) :: :ok
  def unload_database(id) when is_atom(id), do: GenServer.call(Loader, {:unload_database, id})
  def unload_database(%{id: id}), do: unload_database(id)

  defp lookup_all(ip, opts) do
    lookup_all(ip, opts, Loader.loaded_databases())
  end

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
