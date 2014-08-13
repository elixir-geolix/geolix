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
  db_cities: "/path/to/cities/db",
  db_countries: "/path/to/countries/db"
```

An appropriate filename will be automatically appended to the path.

It is also possible to (re-) configure the loaded databases during runtime:

```elixir
iex(1)> Geolix.set_db_cities("/path/to/cities/db")
:ok
iex(2)> Geolix.set_db_countries("/path/to/countries/db")
:ok
```

If Geolix cannot find the database it will output a message onto your
console but still return `:ok`. Lookups for an IP with no suitable database
loaded always return `nil` (city, country, or both).


## Usage

Geolix can be used via direct GenServer calls or the available convencience
methods:

```elixir
iex(1)> Geolix.lookup({ 127, 0, 0, 1 })
%{ city:    ... ,
   country: ... }
iex(2)> Geolix.lookup(:city, { 127, 0, 0, 1 })
%{ ... }
iex(3)> Geolix.lookup(:country, { 127, 0, 0, 1 })
%{ ... }
```

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
