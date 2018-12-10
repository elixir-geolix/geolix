use Mix.Config

if Mix.env() == :test do
  config :geolix, pool: [size: 1, max_overflow: 0]
end
