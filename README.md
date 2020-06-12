# Geolix

IP information lookup provider.

__Note__: If you are reading this on [GitHub](https://github.com/elixir-geolix/geolix) then the information in this file may be out of sync with the [Hex package](https://hex.pm/packages/geolix). If you are using this library through Hex please refer to the appropriate documentation on HexDocs (link available on Hex).

## Package Setup

To use Geolix with your projects, edit your `mix.exs` file and add the project as a dependency:

```elixir
defp deps do
  [
    # ...
    {:geolix, "~> 1.0"},
    # ...
  ]
end
```

If you want to use a manual supervision approach (without starting the application) please look at the inline documentation of `Geolix.Supervisor`.

## Application Configuration

To get started you need to define one or more `:databases` to use for lookups. Each database definition is a map with at least two fields:

- `:id` - an identifier for this database, usable to limit lookups to a single database if you have defined more than one
- `:adapter` - the adapter module used to handle lookup requests. See the part "Adapters" in this document for additional information

Depending on the adapter you may need to provide additional values.

### Configuration (static)

One option for configuration is using a static configuration, i.e. for two databases handled by the adapter `MyAdapter`:

```elixir
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
```

### Configuration (dynamic)

If there are any reasons you cannot use a pre-defined configuration you can also configure an initializer module to be called before starting the top-level suprevisor or alternatively for each individual database.

This may be the most suitable configuration if you have the database located in the `:priv_dir` of your application.

```elixir
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
```

Above example illustrates both types of dynamic initialization.

The top-level initializer is called as defined (`{mod, fun}` or `{mod, fun, args}`) and expected to always return `:ok`. At the database level the current database configuration is passed as the first parameter with optional `{m, f, a}` parameters following. It is expected that this function return the new, complete configuration.

If you choose to use the dynamic database initialization the only requirement for your config file is a plain `%{init: {MyInitModule, :my_init_fun}}` entry. Every additional field in the example is only used for illustration and only required for the complete return value.

### Configuration (runtime)

If you do not want to use a pre-defined or dynamically initialized configuration you can also define adapters at runtime. This may be useful in a testing environment.

```elixir
iex(1)> Geolix.load_database(%{
...(1)>   id: :runtime_city,
...(1)>   adapter: MyAdapter,
...(1)>   source: "/absolute/path/to/city.db"
...(1)> })
:ok
```

Please be aware that these databases will not be reloaded if, for any reason, the supervisor/application is restarted.

Running `load_database/1` on an already configured database (matched by `:id`) will reload/replace it without persisting the configuration. On success a result of `:ok` will be returned otherwise a tuple in the style of `{:error, message}`. The individual errors are defined by the adapter.

## Adapters

All the work done by geolix is handled using adapters. These adapters can use a database, a webservice or any other means available to handle your lookup requests.

Known adapters:

- [`Geolix.Adapter.Fake`](#fake-adapter)
- [`Geolix.Adapter.LookupCache`](https://github.com/elixir-geolix/adapter_lookup_cache)
- [`Geolix.Adapter.MMDB2`](https://github.com/elixir-geolix/adapter_mmdb2)

For detailed information how to configure the adapter of your choice please read the adapter's configuration.

### Fake Adapter

Pre-packaged is a fake/static adapter (`Geolix.Adapter.Fake`) working on a plain `Agent` holding your IP lookup responses. An example of how you might use this adapter:

```elixir
config :geolix,
  databases: [
    %{
      id: :country,
      adapter: Geolix.Adapter.Fake,
      data: %{
        {1, 1, 1, 1} => %{country: %{iso_code: "US"}},
        {2, 2, 2, 2} => %{country: %{iso_code: "GB"}}
      }
    }
  ]
```

Please refer to the inline documentation of the `Geolix.Adapter.Fake` module for more details.

### Custom Adapters

If you need a different database or have other special needs for lookups you can write your own adapter. The only requirement is the usage of the `Geolix.Adapter` behaviour.

As a starting point you can take a close look at the aforementioned `Geolix.Adapter.Fake` implementation.

## Database Loading

### Loading Errors

If the configuration is erroneous a message will be sent to `Logger` with the level `:error`. Any other error during the load process is expected to be defined and logged by the adapter itself.

### State Retrieval

All databases are loaded, unless you called `Geolix.load_database/1`, asynchronously. This includes configured databases loaded upon application start.

The database loader allows you to access the current state of loading:

```elixir
iex(1)> Geolix.Database.Loader.loaded_databases()
[:city]

iex(2)> Geolix.Database.Loader.registered_databases()
[:city, :country]
```

Above example demonstrates a state where the database `:country` is known but not completely loaded yet. Please be aware that both lists are unsorted.

### Reloading

To trigger a forceful reload of all databases configured in the application environment you can use `Geolix.reload_databases/0` to do so. This uses an internal `GenServer.cast/2` so a slight delay will occur.

### Unloading

Calling `Geolix.unload_database/1` with a database id will unload this database. As this is done in a lazy fashion it will still be kept in memory while not being reloaded or used for lookups. If the database is configured via application environment it will still be reloaded as usual in case of a supervisor or application restart.

## Basic Usage

Lookups are done using `Geolix.lookup/1,2`:

```elixir
iex(1)> Geolix.lookup("127.0.0.1")
%{
  city: %{...},
  country: %{...}
}

iex(2)> Geolix.lookup({127, 0, 0, 1}, where: :my_database)
%{...}
```

Full documentation is available inline in the `Geolix` module and at [https://hexdocs.pm/geolix](https://hexdocs.pm/geolix).

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
