use Mix.Config

config :geolix,
  databases: [
    { :city,    "../../data/GeoLite2-City.mmdb"    },
    { :country, "../../data/GeoLite2-Country.mmdb" }
  ],
  pool: [ size: 1, max_overflow: 0 ]
