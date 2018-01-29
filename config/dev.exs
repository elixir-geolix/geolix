use Mix.Config

create_path = fn file ->
  [__DIR__, file]
  |> Path.join()
  |> Path.expand()
end

config :geolix,
  databases: [
    %{
      id: :asn,
      adapter: Geolix.Adapter.MMDB2,
      source: create_path.("../data/GeoLite2-ASN.mmdb")
    },
    %{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source: create_path.("../data/GeoLite2-City.mmdb")
    },
    %{
      id: :country,
      adapter: Geolix.Adapter.MMDB2,
      source: create_path.("../data/GeoLite2-Country.mmdb")
    }
  ],
  pool: [size: 5, max_overflow: 10]
