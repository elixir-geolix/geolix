use Mix.Config

config :geolix,
  databases: [
    { :city,    "./data/GeoLite2-City.mmdb.gz"    },
    { :country, "./data/GeoLite2-Country.mmdb.gz" }
  ],
  pool: [ size: 5, max_overflow: 10 ]
