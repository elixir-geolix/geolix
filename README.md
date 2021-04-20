# Geolix

[![Test](https://github.com/elixir-geolix/geolix/actions/workflows/test.yml/badge.svg)](https://github.com/elixir-geolix/geolix/actions/workflows/test.yml)
[![Module Version](https://img.shields.io/hexpm/v/geolix.svg)](https://hex.pm/packages/geolix)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/geolix/)
[![Total Download](https://img.shields.io/hexpm/dt/geolix.svg)](https://hex.pm/packages/geolix)
[![License](https://img.shields.io/hexpm/l/geolix.svg)](https://github.com/elixir-geolix/geolix/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/elixir-geolix/geolix.svg)](https://github.com/elixir-geolix/geolix/commits/master)

IP information lookup provider.

## Package Setup

To use Geolix with your projects, edit your `mix.exs` file and add the project as a dependency:

```elixir
defp deps do
  [
    # ...
    {:geolix, "~> 2.0"},
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

All the work done by Geolix is handled using adapters. These adapters can use a database, a webservice or any other means available to handle your lookup requests.

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

Adapters are expected to adhere to the `Geolix.Adapter` behaviour. As a starting point for writing a custom adapter you can look at the packaged `Geolix.Adapter.Fake`.

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

## Copyright and License

Copyright (c) 2016 Marc Neudert

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
