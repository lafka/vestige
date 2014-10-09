defmodule Vestige do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
       worker(Vestige.Router, [], function: :start)
    ]

    opts = [strategy: :one_for_one, name: Vestige.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
