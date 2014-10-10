defmodule Vestige.Mixfile do
  use Mix.Project

  def project do
    [ app: :vestige,
      version: "0.0.1",
      elixir: "~> 1.0.0",
      elixirc_paths: ["lib", "web"],
      deps: deps,
      aliases: aliases]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { Vestige, [] },
      applications: [:phoenix, :cowboy, :logger]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [ {:exrm, "~> 0.14.7"},
      {:phoenix, "0.4.1"},
      {:cowboy, "~> 1.0.0"}
    ]
  end

  defp aliases do
    [dock: &build_docker/1]
  end

  defp build_docker(_) do
    tag = "#{project[:app]}:#{project[:version]}"
    Mix.env :prod

    Mix.shell.info "Removing old binaries and release"
    {:ok, _} = File.rm_rf __DIR__ <> "/_build/prod"
    {:ok, _} = File.rm_rf __DIR__ <> "/rel/#{project[:app]}"

    Mix.shell.info "Building docker release #{tag}"
    :ok = Mix.Task.run "release"

    env = case System.get_env("DOCKER_HOST") do
      nil -> []
      host -> [{"DOCKER_HOST", host}]
    end

    case System.cmd "docker", ["build", "-t", tag, "."], [{:env, env}] do
      {_, 0} ->
        Mix.shell.info "ok: #{tag}"

      {err, code} ->
        IO.write :stderr, err
        System.halt code
    end
  end
end
