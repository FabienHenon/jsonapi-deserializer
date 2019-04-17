defmodule JsonApiDeserializer.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :jsonapi_deserializer,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      package: package(),
      preferred_cli_env: [espec: :test],
      source_url: "https://github.com/FabienHenon/jsonapi-deserializer",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
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
      {:espec, "~> 1.6.5", only: :test},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:jason, "~> 1.1"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Fabien Henon"],
      links: %{
        "GitHub" => "https://github.com/FabienHenon/jsonapi-deserializer"
      }
    ]
  end

  defp description do
    """
    A json api deserializer library for Elixir projects
    """
  end

  defp aliases do
    [
      espec: ["espec"],
      test: ["espec"]
    ]
  end
end
