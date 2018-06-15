defmodule LTI.Mixfile do
  use Mix.Project

  def project do
    [
      app: :lti,
      deps: deps(),
      description: description(),
      elixir: "~> 1.5",
      name: "LTI",
      package: package(),
      elixirc_paths: ["lib"],
      source_url: "https://github.com/defactosoftware/lti",
      start_permanent: true,
      version: "0.1.1"
    ]
  end

  defp description do
    """
    A module to easily launch LTI modules.
    """
  end

  defp package do
    [
      name: :lti,
      maintainers: ["Marcel Horlings"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/defactosoftware/lti"}
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]}
    ]
  end
end
