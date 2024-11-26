defmodule Aozora.MixProject do
  use Mix.Project

  def project do
    [
      app: :aozora,
      version: "0.0.1",
      git_path: "https://github.com/aozora/aozora",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Aozora.Application, []},
  
    ]
  end

  def cli do
    [
      # default_task: "dev.start"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dotenv, "~> 3.0"},
      {:finch, "~> 0.19"},
      {:jason, "~> 1.4"},
      {:timex, "~> 3.7"},
      {:tds, "~> 2.3"},
      {:ecto_sql, "~> 3.0"},
      {:mox, "~> 1.0", only: [:test, :dev]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
