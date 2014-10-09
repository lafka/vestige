defmodule Vestige.PageController do
  use Phoenix.Controller

  def index(conn, _params) do
    key = File.read! Application.get_env(:vestige, :key)
    render conn, "index", %{key: key}
  end

  def not_found(conn, _params) do
    render conn, "not_found"
  end

  def error(conn, _params) do
    render conn, "error"
  end
end
