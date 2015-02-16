defmodule Geolix.Mixfile do
  use Mix.Project

  @url_docs "http://hexdocs.pm/geolix"
  @url_github "https://github.com/mneudert/geolix"

  def project do
    [ app:           :geolix,
      name:          "Geolix",
      description:   "MaxMind GeoIP2 database reader/decoder",
      package:       package,
      version:       "0.7.0",
      elixir:        "~> 1.0",
      deps:          deps(Mix.env),
      docs:          docs,
      test_coverage: [ tool: ExCoveralls ]]
  end

  def application do
    [ applications: [ :logger ],
      mod:          { Geolix, [] } ]
  end

  def deps(:docs) do
    deps(:prod) ++
      [ { :earmark, "~> 0.1" },
        { :ex_doc,  "~> 0.7" } ]
  end

  def deps(:test) do
    deps(:prod) ++
      [ { :dialyze,     "~> 0.1" },
        { :excoveralls, "~> 0.3" } ]
  end

  def deps(_) do
    [ { :poolboy, "~> 1.0" } ]
  end

  def docs do
    [ main:       "README",
      readme:     "README.md",
      source_ref: "v0.7.0",
      source_url: @url_github ]
  end

  def package do
    %{ contributors: [ "Marc Neudert" ],
       files:        [ "LICENSE", "mix.exs", "README.md", "lib" ],
       licenses:     [ "Apache 2.0" ],
       links:        %{ "Docs" => @url_docs, "Github" => @url_github }}
  end
end
