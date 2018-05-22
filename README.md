# Geolix

MaxMind GeoIP2 database reader/decoder.

__Note__: If you are reading this on
[GitHub](https://github.com/elixir-geolix/geolix) then the information in this
file may be out of sync with the [Hex package](https://hex.pm/packages/geolix).
If you are using this library through Hex please refer to the appropriate
documentation on HexDocs (link available on Hex).

## Package Setup

To use Geolix with your projects, edit your `mix.exs` file and add the project
as a dependency:

```elixir
defp deps do
  [
    # ...
    {:geolix, "~> 0.16"}
    # ...
  ]
end
```

### Package Startup (application)

Probably the easiest way to manage startup is by
adding `:geolix` to the list of applications:

```elixir
def application do
  [
    applications: [
      # ...
      :geolix
      # ...
    ]
  ]
end
```

### Package Startup (manual supervision)

A second possible approach is to take care of supervision yourself. This
means you should add `:geolix` to your included applications instead:

```elixir
def application do
  [
    included_applications: [
      # ...
      :geolix
      # ...
    ]
  ]
end
```

And also add the appropriate `Geolix.Supervisor` to your hierarchy:

```elixir
# in your application/supervisor
children = [
  # ...
  supervisor(Geolix.Supervisor, [])
  # ...
]
```

## Application Configuration

To get started you need to define one or more `:databases` to use for lookups.
Each database definition is a map with at least two fields:

- `:id` - an identifier for this database, usable to limit lookups to a single
  database if you have defined more than one
- `:adapter` - the adapter module used to handle lookup requests. See the part
  "Adapter Configuration" in this document for additional information

Depending on the adapter you may need to provide additional values.

### Configuration (static)

One option for configuration is using a static configuration, i.e. for two
databases handled by the pre-packaged adapter `Geolix.Adapter.MMDB2`:

```elixir
config :geolix,
  databases: [
    %{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source: "/absolute/path/to/cities/db"
    },
    %{
      id: :country,
      adapter: Geolix.Adapter.MMDB2,
      source: "/absolute/path/to/countries/db"
    }
  ]
```

### Configuration (dynamic)

If there are any reasons you cannot use a pre-defined configuration you can also
configure an initializer module to be called before starting the top-level
suprevisor or alternatively for each individual database.

This may be the most suitable configuration if you have the database located
in the `:priv_dir` of your application.

```elixir
config :geolix,
  init: {MyInitModule, :my_init_fun_toplevel}

config :geolix,
  databases: [
    %{
      id: :dynamic_country,
      adapter: Geolix.Adapter.MMDB2,
      init: {MyInitModule, :my_init_fun_database}
    }
  ]

defmodule MyInitModule do
  @spec my_init_fun_toplevel() :: :ok
  def my_init_fun_toplevel() do
    priv_dir = Application.app_dir(:my_app, "priv")

    databases = [
      %{
        id: :dynamic_city,
        adapter: Geolix.Adapter.MMDB2,
        source: Path.join([priv_dir, "GeoLite2-City.mmdb"])
      }
      | Application.get_env(:geolix, :databases, [])
    ]

    Application.put_env(:geolix, :databases, databases)
  end

  @spec my_init_fun_database(map) :: map
  def my_init_fun_database(%{id: :dynamic_country} = database) do
    priv_dir = Application.app_dir(:my_app, "priv")

    %{database | source: Path.join([priv_dir, "GeoLite2-Country.mmdb"])}
  end
end
```

Above example illustrates both types of dynamic initialization.

The top-level initializer is called without arguments and expected to always
return `:ok`. At the database level the current database configuration is
passed as the first (and only) parameter and the new, complete configuration
is expected as the return.

If you choose to use the dynamic database initialization the only requirement
for your config file is a plain `%{init: {MyInitModule, :my_init_fun}}` entry.
Every additional field in the example is only used for illustration and only
required for the complete return value.

### Configuration (system environment)

Each of the static config values can be grabbed upon start (or restart) from
your current system environment:

```elixir
config :geolix,
  databases: [
    %{
      id: :system_city,
      adapter: Geolix.Adapter.MMDB2,
      source: {:system, "SOME_SYSTEM_ENV_VARIABLE"}
    },
    %{
      id: :system_country,
      adapter: Geolix.Adapter.MMDB2,
      source: {:system, "SOME_VARIABLE", "/path/to/fallback.mmdb2"}
    }
  ]
```

### Configuration (runtime)

If you do not want to use a pre-defined or dynamically initialized configuration
you can also define adapters at runtime. This may be useful in a testing
environment.

```elixir
iex(1)> Geolix.load_database(%{
...(1)>   id: :runtime_city,
...(1)>   adapter: Geolix.Adapter.MMDB2,
...(1)>   source: "/absolute/path/to/cities/db.mmdb"
...(1)> })
:ok
iex(2)> Geolix.load_database(%{
...(2)>   id: :runtime_country,
...(2)>   adapter: Geolix.Adapter.MMDB2,
...(2)>   source: {:system, "SOME_SYSTEM_ENV_VARIABLE"}
...(2)> })
:ok
```

Please be aware that these databases will not be reloaded if, for any reason,
the supervisor/application is restarted.

Running `load_database/1` on an already configured database (matched by `:id`)
will reload/replace it without persisting the configuration. On success a result
of `:ok` will be returned otherwise a tuple in the style of `{:error, message}`.
The individual errors are defined by the adapter.

## Adapter Configuration

### Geolix.Adapter.MMDB2

This is the default pre-packaged adapter for usage with the databases
provided by MaxMind. Depending on the details of your configuration you may
need to fetch a suitable distribution of the
[MaxMind GeoIP2](https://www.maxmind.com/en/geoip2-databases)
database (or the free [GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/)
variant).

The adapter requires the `:source` configuration field to point to the database
to use for lookups:

```elixir
config :geolix,
  databases: [
    %{
      id: :mmdb2,
      adapter: Geolix.Adapter.MMDB2,
      source: "/absolute/path/to/db.mmdb"
    }
  ]
```

To avoid any problems with finding the file you should always provide an
absolute path to the database file (most likely with the `.mmdb` extension).

By default it is expected that all databases are provided uncompressed.
The only compression directly supported is `gzip` (not `zip`!) if the
database source configured ends in `.gz`. If the loader detects a
tarball (`.tar` or `.tar.gz`) the first file in the archive ending in `.mmdb`
will be loaded.

#### Floating Point Precision

Please be aware that all values of the type `float` are rounded to 4 decimal
digits and `double` values to 8 decimal digits.

This might be changed in the future if there are datasets known to return
values with a higher precision.

#### Remote Sources

If you configure a database with a filename starting with "http" (yep, also
matches "https"), the application will request it from that location.

Returning a status of `200` and the actual contents of the database then
results in the regular loading process. Using this configuration you can
load a database during startup from basically any location you can reach.

_Note_: Please be aware of the drawbacks of remote files! You should take into
account the startup times as the file will be requested during
`GenServer.init/1`. Unstable or slow networks could result in nasty timeouts.

_Note_: Be responsible with the source you configure! Having a public download
mirror (or the official MaxMind location) set might flag you as a
"not so nice person". Ideally use your own server or online storage.

## Database Loading

### Loading Errors

Erros occurring during database load are sent to `Logger` with level `:error`.
The contain an atom with the specific error (like `:enoent`) and, in some cases,
are more readable error message.

The errors are defined by the adapter.

### Reloading

To trigger a forceful reload of all databases configured in the application
environment you can use `Geolix.reload_databases/0` to do so. This uses an
internal `GenServer.cast/2` so a slight delay will occur.

### Unloading

Calling `Geolix.unload_database/1` with a database id will unload this database.
As this is done in a lazy fashion it will still be kept in memory while not
being reloaded or used for lookups. If the database is configured via
application environment it will still be reloaded as usual in case of a
supervisor or application restart.

## Usage

Lookups are done using `Geolix.lookup/1,2`:

```elixir
iex(1)> Geolix.lookup("127.0.0.1")
%{
  city: %Geolix.Result.City{...},
  country: %Geolix.Result.Country{...}
}

iex(2)> Geolix.lookup({127, 0, 0, 1}, [as: :raw, where: :city])
%{...}
```

Using `Geolix.lookup/2` with only one parameter (the IP) will lookup the
information on all registered databases, returning `nil` if the IP was not
found.

Lookup options:

* `:as` - Return the result as a `:struct` or `:raw` (plain map)
* `:locale` - Language (atom) to fetch information for.
  Only affects "top level" struct values. Defaults to `:en`.
* `:timeout` - GenServer call timeout for the lookup. Defaults to `5_000`.
* `:where` - Lookup information in a single registered database

Every non-nil result will include the IP as a tuple either directly in the
result field `:ip_address` or inside `%{traits: %{ip_address: ...}}` if
a city or country (or enterprise) database is used.

_Note_: Please be aware that all results for enterprise databases are returned
using separate structs if the data is not already included in the regular
databases. This may change in the future.

## Custom Adapters

If you need a different database or have other special needs for lookups you
can write your own adapter and configure it.

Each adapter is expected to adhere to the `Geolix.Adapter` behaviour.

The MMDB2 adapter (`Geolix.Adapter.MMDB2`) is pre-packaged and usable once you
configure it. For testing you can use a fake adapter (`Geolix.Adapter.Fake`)
working on a plain `Agent` holding your IP lookup responses.

## Additional Stuff

### Benchmarking

If you are curious about how long a lookup of an IP takes, you can
measure it using the erlang `:timer` module:

```elixir
iex(1)> # display runtime in microseconds and the result
iex(2)> :timer.tc(fn -> Geolix.lookup({108, 168, 255, 243}) end)
{
  1337,
  %{
    city: ... ,
    country: ...
  }
}

iex(3)> # display only runtime in microseconds
iex(4)> (fn ->
...(4)>   {t, _} = :timer.tc(fn -> Geolix.lookup({82, 212, 250, 99}) end)
...(4)>   t
...(4)> end).()
1337
```

The time returned are the `microseconds` of the complete lookup including
every overhead by for example the process pool. For more details refer to the
[official erlang documentation](http://www.erlang.org/doc/man/timer.html#tc-1).

### Result Verification

For (ongoing) verification of the result accuracy a special test environment
is configured for each travis run.

This environment performs the following 4 steps:

- generate a set of random IPs
- lookup using geolix
- lookup using python ([geoip2](https://github.com/maxmind/GeoIP2-python))
- compare the results

To run these tests on a local machine please refer to the travis commands
executed on each run (`.travis.yml`).

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

License information about the supported
[MaxMind GeoIP2 Country](http://www.maxmind.com/en/country),
[MaxMind GeoIP2 City](http://www.maxmind.com/en/city) and
[MaxMind GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/) databases
can be found on their respective sites.
