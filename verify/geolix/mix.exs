defmodule Geolix.Verification.Mixfile do
  use Mix.Project

  def project do
    [ app:       :geolix_verification,
      version:   "0.0.1",
      elixir:    "~> 1.0",
      deps:      deps,
      deps_path: "../../deps",
      lockfile:  "../../mix.lock" ]
  end

  def application, do: [ applications: [ :geolix ] ]

  defp deps, do: [{ :geolix, path: "../../" }]
end
