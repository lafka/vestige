defmodule Vestige.BuildController do
  use Phoenix.Controller
  require Logger
  import Plug.Conn

  defp e(data), do: Poison.encode!(data)

  @doc """
  Builds something using the provided request body or ?build= query
  param. This is as insecure as it gets, we only escape `'` for
  increased usability.
  """
  def build(conn, params) do
    item = Vestige.Item.from_path params["item"]

    case read_body conn do
      {:ok, buf, conn} ->
        buf = cond do
          "" == buf -> params["build"] |> URI.decode
          true -> buf
        end

        {:ok, build} = Vestige.Build.init(item, buf)
        conn = Plug.Conn.send_chunked conn, 200
        waitfor_pid conn, build

      {:error, err} ->
        text conn, 500, "weird error: #{inspect err}"
    end
  end

  defp waitfor_pid(conn, build) do
    port = build.port
    receive do
      {^port, {:data, data}} ->
        File.write! build.log, data, [:binary, :append]
        Plug.Conn.chunk(conn, data) |> chunk_ret conn, build

      {^port, {:exit_status, status}} ->
        Vestige.Build.set_status build, status
        conn

      r when not r in [{:cowboy_req, :resp_sent},
                       {:plug_conn, :sent}] ->
        Logger.debug "debug got #{inspect r}"
        waitfor_pid conn, build
    end
  end

  defp chunk_ret({:ok, conn}, _oldconn, build), do: waitfor_pid(conn, build)
  defp chunk_ret({:error, _} = err, conn, build) do
    Logger.debug "SSE-err: #{inspect err}"
    Port.close build.port
    conn
  end

  def not_found(conn, _params) do
    render conn, "not_found"
  end

  def error(conn, _params) do
    render conn, "error"
  end
end
