defmodule DialyzerMissing.MixProject do
  use Mix.Project
  def project, do: [app: :dialyzer_missing, version: "0.1.0", deps: [{:credo, "~> 1.7", only: :dev, runtime: false}]]
end
