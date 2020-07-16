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

Every lookup request is passed to all configured databases:

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

Above configuration will use the adapter `MyAdapter` and return a result for an example `:city` and `:country` database. The exact configuration values you need to provide are defined by the adapter you are using.

More details on database configuration can be found inline at the main `Geolix` module.

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
