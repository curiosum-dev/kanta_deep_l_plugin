defmodule Kanta.DeepL.Plugin.MixProject do
  use Mix.Project

  def project do
    [
      app: :kanta_deep_l_plugin,
      description: "Kanta plugin for using DeepL translator from the UI",
      version: "0.1.1",
      elixir: "~> 1.14",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:jason, ">= 1.0.0"},
      {:phoenix_live_view, "~> 0.18"},
      {:kanta, ">= 0.4.1", optional: true},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:doctor, "~> 0.21.0", only: :dev},
      {:versioce, "~> 2.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/curiosum-dev/kanta_deep_l_plugin"},
      files: ~w(lib LICENSE.md mix.exs README.md)
    ]
  end
end
