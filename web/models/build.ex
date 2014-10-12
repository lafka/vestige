defmodule Vestige.Build do
  alias Vestige.Item

  @builddir "builds"

  defstruct id: nil,
            ref: nil,
            path: nil,
            status: -1,
            log: nil,
            command: nil,
            ctime: nil,
            mtime: nil,
            port: nil

  def init(%Item{name: name} = item, command) do
    builduid = uid
    buildpath = :filename.join [storage_path, @builddir, name, builduid]
    archive_git item.path, buildpath
    File.mkdir_p! buildpath

    bin = :os.find_executable('sh')

    build = %Vestige.Build{
                   id: builduid,
                   path: buildpath,
                   log: logpath(buildpath),
                   command: command,
                   ctime: statctime(buildpath),
                   mtime: statmtime(buildpath)}

    stash build


    path = String.to_char_list Path.join(System.cwd, "bin") <> ":" <> System.get_env "PATH"
    port = Port.open({:spawn_executable, bin},
                     [:stream, :binary, IO.inspect({:args, ["-c",
"exec " <> command]}),
                      :use_stdio, :stderr_to_stdout, :exit_status,
                      {:cd, buildpath}, {:env, [{'PATH', path}]}])

    {:ok, %{build | port: port}}
  end

  defp escape(command), do:
    String.replace(command, "'", "\\'")

  defp archive_git(from, to) do
    System.cmd "git", ["clone", "--single-branch", "--depth", "1", "file://" <> from, to]
  end

  def set_status(build, status) do
    %{build | status: status} |> stash
  end

  def logpath(path), do: :filename.join(path, "vestige-log")
  defp statctime(path), do: File.stat!(path).ctime
  defp statmtime(path), do: File.stat!(path).mtime

  defp stash(%Vestige.Build{path: path} = build) do
    stashpath = :filename.join(path, "_build.vestige")
    File.write! stashpath, :erlang.term_to_binary(%{build | port: nil})
  end


  def from_path(<<"/", _ :: binary>> = path) do
    case File.read(:filename.join(path, "_build.vestige")) do
      {:ok, buf} -> {:ok, buf |> :erlang.binary_to_term}
      {:error, _} = err -> err
    end
  end

  defp uid do
    :crypto.hash(:sha,
                 make_ref
                  |> :erlang.term_to_binary)
      |> :binary.decode_unsigned
      |> Integer.to_string(16)
      |> String.downcase
  end

  defp storage_path, do: Application.get_env(:vestige, :storage_path)
end
