defmodule Vestige.ItemController do
  use Phoenix.Controller

  defp e(data), do: Poison.encode!(data)

  def create(conn, params) do
    cond do
      nil == params["name"] ->
            json conn, 400, e %{"error" => "`name` not set"}

      nil == params["origin"] ->
            json conn, 400, e %{"error" => "`origin` not set"}

      true ->
        item = %Vestige.Item{name: params["name"], origin: params["origin"]}
        case Vestige.Item.load item do
          {:error, err} ->
            json conn, 500, e %{"error" => "#{inspect err}"}

          {:ok, item} ->
            json conn, item
        end
    end
  end

  @doc """
  Loads an item!
  """
  def item(conn, params) do
    item = Vestige.Item.from_path params["item"]
    render conn, "item", %{item: item}
  end

  @doc """
  Handles call to re-sync a repository.
  takes two query parameters: `ref` and `origin` for the commit
  reference (branch,tag etc) and the remote source
  """
  def fetch(conn, params) do
    {:ok, item} = Vestige.Item.load %Vestige.Item{name: params["item"],
                                                  origin: params["origin"]}
    opts = [stderr_to_stdout: true, cd: item.path]

    if params["origin"] do
      %Vestige.Item{path: path} = item
      {_, _} = System.cmd "git", ["remote", "remove", "origin"], opts
      {_, _} = System.cmd "git", ["remote", "add", "origin", params["origin"]], opts
    end

    case System.cmd "git", ["fetch", "origin"], opts do
      {_, 0} = res ->
        text conn, 204, ""

      {err, _} ->
        text conn, 500, err
    end
  end

  def not_found(conn, _params) do
    render conn, "not_found"
  end

  def error(conn, _params) do
    render conn, "error"
  end
end
