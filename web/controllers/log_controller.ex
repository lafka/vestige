defmodule Vestige.LogController do
  use Phoenix.Controller
  require Logger

  defp e(data), do: Poison.encode!(data)

  def show(conn, params) do
    path = :filename.join([Application.get_env(:vestige, :storage_path),
          "builds",
          params["item"],
          params["build"]])

    {:ok, build} = Vestige.Build.from_path path

    case File.read build.log do
      {:ok, buf} ->
        text conn, buf

      {:error, :enoent} ->
        text conn, 404, ""
    end
  end
end
