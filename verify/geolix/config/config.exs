use Mix.Config

path_city =
     [ __DIR__, "../../../data/GeoLite2-City.mmdb" ]
  |> Path.join()
  |> Path.expand()

path_country =
     [ __DIR__, "../../../data/GeoLite2-Country.mmdb" ]
  |> Path.join()
  |> Path.expand()

config :geolix,
  databases: [
    city:    path_city,
    country: path_country
  ],
  pool: [ size: 1, max_overflow: 0 ]
