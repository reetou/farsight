defmodule Farsight.MixProject do
  use Mix.Project

  def project do
    [
      app: :farsight,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_paths: ["lib"],
      license: "Apache-2.0",
      # Docs
      name: "Farsight",
      source_url: "https://github.com/reetou/farsight",
      homepage_url: "https://github.com/reetou/farsight",
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Farsight.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "Farsight",
      # logo: "assets/logo.png",
      extras: ["README.md"]
    ]
  end
end
