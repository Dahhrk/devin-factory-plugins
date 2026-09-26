defmodule CredoMissing.MixProject do
  use Mix.Project
  def project, do: [app: :credo_missing, version: "0.1.0", deps: [{:dialyxir, "~> 1.4", only: :dev, runtime: false}]]
end
