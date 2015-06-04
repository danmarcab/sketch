defmodule Sketch.Mixfile do
  use Mix.Project

  def project do
    [app: :sketch,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp description do
    """
    Sketch is a simple library to build and query graphs
    """
  end

  defp package do
    [files: ~w(lib mix.exs README.md LICENSE),
     contributors: ["Daniel Marín Cabillas"],
     licenses: ["Apache 2.0"],
     links: %{"Github" => "https://github.com/danmarcab/sketch"}]
  end

  defp deps do
    []
  end
end
