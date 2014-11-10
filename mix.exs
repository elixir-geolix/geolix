defmodule Geolix.Mixfile do
  use Mix.Project

  def project do
    [ app:           :geolix,
      name:          "Geolix",
      source_url:    "https://github.com/mneudert/geolix",
      version:       "0.4.2",
      elixir:        "~> 1.0",
      deps:          deps(Mix.env),
      docs:          [ readme: true, main: "README" ],
      test_coverage: [ tool: ExCoveralls ]]
  end

  def application do
    [ applications: [ :logger ],
      mod:          { Geolix, [] } ]
  end

  def deps(:docs) do
    deps(:prod) ++
      [ { :earmark, "~> 0.1" },
        { :ex_doc,  "~> 0.6" } ]
  end

  def deps(:test) do
    deps(:prod) ++
      [ { :dialyze,     "~> 0.1" },
        { :excoveralls, "~> 0.3" } ]
  end

  def deps(_) do
    [ { :poolboy, "~> 1.0" } ]
  end
end
