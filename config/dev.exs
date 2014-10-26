use Mix.Config

config :geolix,
  databases: [
    { :city,    "./data/GeoLite2-City.mmdb"    },
    { :country, "./data/GeoLite2-Country.mmdb" }
  ]
