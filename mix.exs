defmodule ReqSSE.MixProject do
  use Mix.Project

  def project do
    [
      app: :req_sse,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5 or ~> 1.0"},
      {:server_sent_events, "~> 0.2.0"},
      {:plug, "~> 1.0", only: :test}
    ]
  end
end
