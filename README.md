# Geolix

MaxMind GeoIP2 database reader/decoder.


## Installation

Fetch both the geolix repository and a distribution of the
[MaxMind GeoIP2](http://dev.maxmind.com/geoip/geoip2/downloadable/)
databases (or the free [GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/)
variant).


## Usage

### Standalone

Startup a iex console and start the supervisor:

```elixir
iex(1)> Geolix.start_link()
{ :ok, #PID }
iex(2)> Geolix.set_db_cities("/path/to/cities/db")
:ok
iex(3)> Geolix.set_db_countries("/path/to/countries/db")
:ok
```

If Geolix cannot find the database to add it will output a message onto your
console but still return `:ok`. Lookups for an IP with no suitable database
return nil (city, country, or both).

Now you should be able to lookup IPs using plain gen_server calls or the
available convencience methods:

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

### As Mix-Dependency

Add the following part to your `mix.exs`:

```elixir
def deps do
    [ { :geolix, github: "mneudert/geolix" } ]
end
```

Then start the supervisor somewhere in your code and use it.


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

License information about the supported
[MaxMind GeoIP2 Country](http://www.maxmind.com/en/country),
[MaxMind GeoIP2 City](http://www.maxmind.com/en/city) and
[MaxMind GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/) databases
can be found on their respective sites.
