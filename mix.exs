defmodule Geolix.MixProject do
  use Mix.Project

  @url_github "https://github.com/elixir-geolix/geolix"

  def project do
    [
      app: :geolix,
      name: "Geolix",
      version: "2.1.0-dev",
      elixir: "~> 1.7",
      deps: deps(),
      description: "IP information lookup provider",
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Geolix.Application, []}
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14.0", only: :test, runtime: false}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :underspecs,
        :unmatched_returns
      ],
      plt_core_path: "plts",
      plt_local_path: "plts"
    ]
  end

  defp docs do
    [
      main: "Geolix",
      source_ref: "master",
      source_url: @url_github
    ]
  end

  defp package do
    %{
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @url_github}
    }
  end
end
