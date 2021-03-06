defmodule ZmqBroker.Mixfile do
  use Mix.Project

  def project do
    [app: :zmq_broker,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :maru],
     mod: {ZmqBroker, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:erlzmq, github: "zeromq/erlzmq2"},
      {:httpoison, "~> 0.9.0"},
      {:maru, "~> 0.10"},
      {:ex_json_schema, "~> 0.5.1"},
      {:distillery, "~> 0.10"}
    ]
  end
end

