use Mix.Config

path_city =
     [ __DIR__, "../data/GeoLite2-City.mmdb.gz" ]
  |> Path.join()
  |> Path.expand()

path_country =
     [ __DIR__, "../data/GeoLite2-Country.mmdb.gz" ]
  |> Path.join()
  |> Path.expand()

config :geolix,
  databases: [
    %{
      id:      :city,
      adapter: Geolix.Adapter.MMDB2,
      source:  path_city
    },
    %{
      id:      :country,
      adapter: Geolix.Adapter.MMDB2,
      source:  path_country
    }
  ],
  pool: [ size: 5, max_overflow: 10 ]
