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
Geolix.start_link("/path/to/folder/with/databases")
```

If geolix cannot find a suitable database it will output a message onto your
console, but won't stop itself from starting. Lookups for an IP will simply
return nil for their depending database (city, country, or both).

Now you should be able to lookup IPs using plain gen_server calls:

```elixir
iex> :gen_server.call(:geolix, { :lookup, {127, 0, 0, 1} })
[ city:    ... ,
  country: ... ]
iex> :gen_server.call(:geolix, { :city, {127, 0, 0, 1} })
[ ... ]
iex> :gen_server.call(:geolix, { :country, {127, 0, 0, 1} })
[ ... ]
```

If you are curious on how long a lookup of an IP takes, you can simply measure
it using the erlang :timer module:

```elixir
iex> :timer.tc(fn() -> :gen_server.call(:geolix, { :lookup, {108, 168, 255, 243} }) end)
{ 1337,
  [ city:    ... ,
    country: ... ] }
```

### As Mix-Dependency

Add the following part to your `mix.exs`:

```elixir
def deps do
    [ { :geolix, github: "mneudert/geolix" } ]
end
```

Then start the supervisor somewhere in your code and use it.
