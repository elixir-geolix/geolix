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
  [ { :geolix, github: "mneudert/geolix" } ]
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

config :geolix,
  databases: [
    { :city,    "/path/to/cities/db"    },
    { :country, "/path/to/countries/db" }
  ]
```

An appropriate filename will be automatically appended to the path.

It is also possible to (re-) configure the loaded databases during runtime:

```elixir
iex(1)> Geolix.set_database(:city, "/path/to/cities/db.mmdb")
:ok
iex(2)> Geolix.set_database(:country, "/path/to/countries/db.mmdb")
:ok
```

If Geolix cannot find the database it will return `{ :error, message }`,
otherwise the return value will be `:ok`.


## Usage

Geolix can be used via a convenience GenServer calls:

```elixir
iex(1)> Geolix.lookup({ 127, 0, 0, 1 })
%{ city:    ... ,
   country: ... }
iex(2)> Geolix.lookup(:city, { 127, 0, 0, 1 })
%{ ... }
```

Using `Geolix.lookup/1` will lookup the information on all registered databases,
returning `nil` if the ip was not found. Using `Geolix.lookup/2` will only
return the information in the given database.

The queried ip will be included in every non-nil result returned.

If you are curious on how long a lookup of an IP takes, you can simply measure
it using the erlang :timer module:

```elixir
iex(1)> :timer.tc(fn() -> :gen_server.call(:geolix, { :lookup, {108, 168, 255, 243} }) end)
{ 1337,
  %{ city:    ... ,
     country: ... } }
```


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

License information about the supported
[MaxMind GeoIP2 Country](http://www.maxmind.com/en/country),
[MaxMind GeoIP2 City](http://www.maxmind.com/en/city) and
[MaxMind GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/) databases
can be found on their respective sites.
