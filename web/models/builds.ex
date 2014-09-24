defmodule Vestige.Builds do
  @subdir "builds"

  def get(item) do
    path = :filename.join [Application.get_env(:vestige, :storage_path), @subdir, item]

    case File.ls path do
      {:ok, files} ->
        files |> Enum.reduce([], fn(uid, acc) ->
          case Vestige.Build.from_path :filename.join [path, uid] do
            {:ok, build} -> [build | acc];
            _ -> acc
          end
        end) |> Enum.reverse |> Enum.slice 0, 10

      _ -> []
    end
  end
end
