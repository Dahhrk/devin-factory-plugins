defmodule Good.MixProject do
  use Mix.Project
  def project do
    [
      app: :good,
      version: "0.1.0",
      deps: [
        {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
        {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
      ]
    ]
  end
end
