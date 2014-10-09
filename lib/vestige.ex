defmodule Vestige do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    create_workdir
    Application.put_env :vestige, :key, maybe_create_sshkey

    children = [
      # Define workers and child supervisors to be supervised
       worker(Vestige.Router, [], function: :start)
    ]

    opts = [strategy: :one_for_one, name: Vestige.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp create_workdir do
    path = Application.get_env(:vestige, :storage_path)
    File.mkdir_p! path
  end

  defp maybe_create_sshkey do
    path = Path.expand "~/.ssh/id_rsa.pub"
    if File.exists? Path.expand path do
      path
    else
      path = Path.join [Application.get_env(:vestige, :storage_path), ".ssh", "id_rsa"]

      if File.exists? path do
        path
      else
        File.mkdir_p! Path.dirname path
        System.cmd "ssh-keygen", ["-f", path, "-N", ""]
      end
    end
  end
end
