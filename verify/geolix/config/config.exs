use Mix.Config

path_asn = Path.expand("../../../data/GeoLite2-ASN.mmdb", __DIR__)
path_city = Path.expand("../../../data/GeoLite2-City.mmdb", __DIR__)
path_country = Path.expand("../../../data/GeoLite2-Country.mmdb", __DIR__)

config :geolix,
  databases: [
    %{
      id: :asn,
      adapter: Geolix.Adapter.MMDB2,
      source: path_asn
    },
    %{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source: path_city
    },
    %{
      id: :country,
      adapter: Geolix.Adapter.MMDB2,
      source: path_country
    }
  ],
  pool: [size: 1, max_overflow: 0]
