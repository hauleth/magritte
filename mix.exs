defmodule Magritte.MixProject do
  use Mix.Project

  def project do
    [
      app: :magritte,
      description: "Ceci n'est pas une pipe - extended pipe operator",
      version: "0.1.2",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      docs: [
        main: "Magritte"
      ],
      package: package(),
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp package do
    [
      licenses: ~w[MIT],
      links: %{
        "GitHub" => "https://github.com/hauleth/magritte"
      }
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
