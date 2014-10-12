defmodule Vestige.Item do

  alias __MODULE__

  defstruct path: nil,
            name: nil,
            origin: nil,
            commits: [],
            builds: []

  @subdir "items"
  @builddir "builds"

  def from_path(<<"/", _ :: binary>> = path) do
    name = String.split(path, "/") |> List.last
    from_path name
  end
  def from_path(name) do
    path = :filename.join([storage_path, @subdir, name])
    %Item{name: name, path: path}
      |> fill_origin
      |> fill_commit_log
      |> fill_builds
  end

  def load(%Item{path: nil, name: name} = item) do
    load %{item | path: :filename.join([storage_path, @subdir, name])}
  end
  def load(%Item{} = item) do
    if File.dir? item.path do
      {:ok, from_path item.path}
    else
      case System.cmd("git", ["clone", "--bare", item.origin, item.path]) do
        {_, 0} ->
          File.mkdir_p! pathsub item.path, @builddir
          {:ok, from_path(item.name)}

        {_, err} ->
          {:error, "can't clone: #{item.origin}"}
      end
    end
  end

  defp storage_path do
    Application.get_env :vestige, :storage_path
  end
  defp storage_path(append) do
    :filename.join(Application.get_env(:vestige, :storage_path), append)
  end

  defp fill_origin(item) do
    {buf, 0} = System.cmd "git", ["remote", "-v"], [cd: item.path]
    [origin|_] = String.split(buf, "\n")
      |> Enum.filter_map &String.match?(&1, ~r/origin\s.*\(fetch\)$/),
                         fn(a) -> String.split(a, ["\t", " "]) |> Enum.at 1 end
    %{item | origin: origin}
  end

  defp fill_commit_log(item) do
    cmd = :os.find_executable('git') |> List.to_string
    {buf, 0} = System.cmd cmd, ["log", "--pretty=oneline"], [cd: item.path]
    buf = String.strip buf, ?\n

    %{item | commits: String.split(buf, "\n")}
  end

  defp fill_builds(item) do
    %{item | builds: Vestige.Builds.get(item.name)}
  end

  defp pathsub(path, item) do
    [name, @subdir | rest ] = String.split(path, ["/", "\\"]) |> Enum.reverse
    [name, @builddir | rest] |> Enum.reverse |> Enum.join "/"
  end
end
