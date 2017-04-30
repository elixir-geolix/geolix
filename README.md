# Geolix

MaxMind GeoIP2 database reader/decoder.


## Installation

Fetch both the Geolix repository and a distribution of the
[MaxMind GeoIP2](https://www.maxmind.com/en/geoip2-databases)
databases (or the free [GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/)
variant).


## Setup

### Dependency

To use Geolix with your projects, edit your `mix.exs` file and add the project
as a dependency:

```elixir
defp deps do
  [ { :geolix, "~> 0.13" } ]
end
```

__Note__: If you are reading this on
[GitHub](https://github.com/elixir-geolix/geolix) then the information in this
file may be out of sync with the [Hex package](https://hex.pm/packages/geolix).
If you are using this library through Hex please refer to the appropriate
documentation on HexDocs (link available on Hex).

### Application/Supervisor Setup

Probably the easiest way to manage startup is by simply
adding `:geolix` to the list of applications:

```elixir
def application do
  [ applications: [ :geolix ] ]
end
```

A second possible approach is to take care of supervision yourself. This
means you should add `:geolix` to your included applications instead:

```elixir
def application do
  [ included_applications: [ :geolix ] ]
end
```

And also add the appropriate `Geolix.Supervisor` to your hierarchy:

```elixir
# in your application/supervisor
children = [
  # ...
  supervise(Geolix.Supervisor, [])
  # ..
]
```

### Configuration

Add the paths of the MaxMind databases you want to use to your project
configuration:

```elixir
use Mix.Config

# static configuration
config :geolix,
  databases: [
    %{
      id:      :city,
      adapter: Geolix.Adapter.MMDB2,
      source:  "/absolute/path/to/cities/db"
    },
    %{
      id:      :country,
      adapter: Geolix.Adapter.MMDB2,
      source:  "/absolute/path/to/countries/db"
    },
    %{
      id:      :enterprise,
      adapter: Geolix.Adapter.MMDB2,
      source:  "http://my.internal.server/database.mmdb"
    }
  ]

# system environment configuration
config :geolix,
  databases: [
    %{
      id:      :system_city,
      adapter: Geolix.Adapter.MMDB2,
      source:  { :system, "SOME_SYSTEM_ENV_VARIABLE" }
    }
  ]
```

_Note_: if you do not want to use absolute paths or system variables please
be aware that any code in the config file is evaluated at compile time.

By default it is expected that all databases are provided uncompressed.
The only compression directly supported is `gzip` (not `zip`!) if the
database source configured ends in `.gz`. There is no support for compressed
tarballs (`.tar.gz`)!

It is also possible to (re-) configure the loaded databases during runtime:

```elixir
iex(1)> Geolix.load_database(%{
...(1)>   id:      :city,
...(1)>   adapter: Geolix.Adapter.MMDB2,
...(1)>   source:  "/absolute/path/to/cities/db.mmdb"
...(1)> })
:ok
iex(2)> Geolix.load_database(%{
...(2)>   id:      :country,
...(2)>   adapter: Geolix.Adapter.MMDB2,
...(2)>   source:  { :system, "SOME_SYSTEM_ENV_VARIABLE" }
...(2)> })
:ok
```

If Geolix cannot find the database it will return `{ :error, message }`,
otherwise the return value will be `:ok`. Running `load_database/1` on an
already configured database will reload/replace it.

If you want to forcefully reload all database configured in the application
environment you can use `Geolix.reload_databases/0` to do so. This uses an
internal `GenServer.cast/2` so a slight delay will occur.

#### Configuration (Remote Files)

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


## Usage

Lookups are done using `Geolix.lookup/1,2`:

```elixir
iex(1)> Geolix.lookup("127.0.0.1")
%{ city:    %Geolix.Result.City{ ... },
   country: %Geolix.Result.Country{ ... }}
iex(2)> Geolix.lookup({ 127, 0, 0, 1 }, [ as: :raw, where: :city ])
%{ ... }
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
result field `:ip_address` or inside `%{ traits: %{ ip_address: ... }}` if
a city or country (or enterprise) database is used.

_Note_: Please be aware that all results for enterprise databases are returned
using separate structs if the data is not already included in the regular
databases. This may change in the future.

### Floating Point Precision

Please be aware that all values of the type `float` are rounded to 4 decimal
digits and `double` values to 8 decimal digits.

This might be changed in the future if there are datasets known to return
values with a higher precision.

### Benchmarking

If you are curious about how long a lookup of an IP takes, you can simply
measure it using the erlang `:timer` module:

```elixir
iex(1)> # display runtime in microseconds and the result
iex(2)> :timer.tc(fn -> Geolix.lookup({ 108, 168, 255, 243 }) end)
{ 1337,
  %{ city:    ... ,
     country: ... } }
iex(3)> # display only runtime in microseconds
iex(4)> (fn ->
...(4)>   { t, _ } = :timer.tc(fn -> Geolix.lookup({ 82, 212, 250, 99 }) end)
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

To run these tests on a local machine please refer to the travis scripts
executed on each run
(i.e. `./travis/verify_install.sh` and `./travis/verify_script.sh`).


## Adapters

If you need a different database or have other special needs for lookups you
can write your own adapter and configure it.

Each adapter is expected to adhere to the `Geolix.Adapter` behaviour.

The MMDB2 adapter (`Geolix.Adapter.MMDB2`) is pre-packaged and usable once you
configure it. For testing you can use a fake adapter (`Geolix.Adapter.Fake`)
working on a plain `Agent` holding your IP lookup responses.


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

License information about the supported
[MaxMind GeoIP2 Country](http://www.maxmind.com/en/country),
[MaxMind GeoIP2 City](http://www.maxmind.com/en/city) and
[MaxMind GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/) databases
can be found on their respective sites.
