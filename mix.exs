defmodule Snowflake.Mixfile do
  use Mix.Project

  @version "1.0.4"
  @url "https://github.com/blitzstudios/snowflake"
  @maintainers ["Weixi Yen"]

  def project do
    [
      name: "Snowflake",
      app: :snowflake,
      version: @version,
      source_url: @url,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      maintainers: @maintainers,
      description: "Elixir Snowflake ID Generator",
      elixir: "~> 1.3",
      package: package(),
      homepage_url: @url,
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [applications: [], mod: {Snowflake, []}]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.4", only: :dev, runtime: false},
      {:benchee, "~> 0.6", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  def docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{github: @url},
      files: ~w(lib) ++ ~w(CHANGELOG.md LICENSE mix.exs README.md)
    ]
  end
end
