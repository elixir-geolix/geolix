defmodule Geolix.Mixfile do
  use Mix.Project

  def project do
    [ app:        :geolix,
      name:       "Geolix",
      source_url: "https://github.com/mneudert/geolix",
      version:    "0.0.5",
      elixir:     ">= 0.14.3",
      deps:       deps(Mix.env),
      docs:       &docs/0 ]
  end

  def application, do: []

  defp deps(:docs) do
    deps(:prod) ++
      [ { :ex_doc,   github: "elixir-lang/ex_doc" },
        { :markdown, github: "devinus/markdown" } ]
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
