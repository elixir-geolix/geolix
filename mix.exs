defmodule Geolix.Mixfile do
  use Mix.Project

  def project do
    [ app:        :geolix,
      name:       "Geolix",
      source_url: "https://github.com/mneudert/geolix",
      version:    "0.0.4",
      elixir:     "~> 0.14.0",
      deps:       deps(Mix.env),
      deps_path:  "_deps",
      docs:       &docs/0 ]
  end

  def application, do: []

  defp deps(:docs) do
    deps(:prod) ++
      [ { :ex_doc, github: "elixir-lang/ex_doc", tag: "6ef80510e5037e3cbcc9bb96bc30daa441e74722" } ]
  end

  defp deps(_) do
    []
  end

  defp docs do
    [ readme:     true,
      main:       "README",
      source_ref: System.cmd("git rev-parse --verify --quiet HEAD") ]
  end
end
