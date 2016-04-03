# Geolix

MaxMind GeoIP2 database reader/decoder.


## Installation

Fetch both the Geolix repository and a distribution of the
[MaxMind GeoIP2](http://dev.maxmind.com/geoip/geoip2/downloadable/)
databases (or the free [GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/)
variant).


## Setup

### Dependency

To use Geolix with your projects, edit your `mix.exs` file and add the project
as a dependency:

```elixir
defp deps do
  [ { :geolix, "~> 0.9" } ]
end
```

You should also update your applications to include all necessary projects:

```elixir
def application do
  [ applications: [ :geolix ] ]
end
```

### Configuration

Add the paths of the MaxMind databases you want to use to your project
configuration:

```elixir
use Mix.Config

# static configuration
config :geolix,
  databases: [
    { :city,    "/path/to/cities/db"    },
    { :country, "/path/to/countries/db" }
  ]

# system environment configuration
config :geolix,
  databases: [
    { :city, { :system, "SOME_SYSTEM_ENV_VARIABLE" }}
  ]
```

#### For Phoenix users

If you want to include a database, you'll need to store your files in a location such as `priv/static/`. From there you'll need to reference the base directory to properly locate the database files:

```elixir
use Mix.Config

config :geolix,
  databases: [
    { :city,    :filename.join(Path.dirname(__DIR__), "priv/static/mmdb/db-city.mmdb")    },
    { :country, :filename.join(Path.dirname(__DIR__), "priv/static/mmdb/db-country.mmdb") }
  ]
```

An appropriate filename will be automatically appended to the path. If the
filename ends in ".gz" it will be loaded as a compressed file.

It is also possible to (re-) configure the loaded databases during runtime:

```elixir
iex(1)> Geolix.set_database(:city, "/path/to/cities/db.mmdb")
:ok
iex(2)> Geolix.set_database(:country, "/path/to/countries/db.mmdb.gz")
:ok
```

If Geolix cannot find the database it will return `{ :error, message }`,
otherwise the return value will be `:ok`. Running `set_database/2` on an
already configured database will reload it.


## Usage

Geolix can be used via convenience GenServer calls:

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
  Only affects "top level" struct values.
* `:where` - Lookup information in a single registered database

Every non-nil result will include the IP as a tuple either directly in the
result field `:ip_address` or inside `%{ traits: %{ ip_address: ... }}` if
a city or country database is used.

### Floating point precision

Please be aware that all values of the type `float` are rounded to 4 decimal
digits and `double` values to 8 decimal digits.

This might be changed in the future if there are datasets known to return
values with a higher precision.

### Benchmarking

If you are curious on how long a lookup of an IP takes, you can simply measure
it using the erlang :timer module:

```elixir
iex(1)> :timer.tc(fn -> Geolix.lookup({ 108, 168, 255, 243 }) end)
{ 1337,
  %{ city:    ... ,
     country: ... } }
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


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

License information about the supported
[MaxMind GeoIP2 Country](http://www.maxmind.com/en/country),
[MaxMind GeoIP2 City](http://www.maxmind.com/en/city) and
[MaxMind GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/) databases
can be found on their respective sites.
