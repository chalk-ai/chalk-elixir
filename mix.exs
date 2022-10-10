defmodule Chalk.Mixfile do
  use Mix.Project

  @source_url "https://github.com/chalk-ai/chalk-elixir"

  def project do
    [
      app: :chalk,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test],
      dialyzer: [
        plt_add_deps: :apps_direct
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.18"},
      {:poison, "~> 4.0"},
      {:jason, "~> 1.1"},
      {:bypass, "~> 2.1", only: [:test]},
      {:credo, "~> 0.5", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.14", only: [:test]},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:telemetry, "~> 1.0"},
      {:mox, "~> 1.0", only: :test},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      description: "An Elixir Library for Chalk's API",
      name: :chalk_elixir,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["Apache 2.0"],
      maintainers: ["Andrew Moreland"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE": [title: "License"],
        "README.md": [title: "Overview"],
        "parameters.md": [],
        "CHANGELOG.md": []
      ],
      main: "readme",
      logo: "assets/chalk-logo.png",
      source_url: @source_url,
      source_ref: "main",
      formatters: ["html"]
    ]
  end
end
