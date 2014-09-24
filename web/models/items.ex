defmodule Vestige.Items do
  @subdir "items"

  def get do
    path = :filename.join Application.get_env(:vestige, :storage_path), @subdir

    path |> File.ls! |> Enum.map fn(item) ->
      Vestige.Item.from_path :filename.join [path, @subdir, item]
    end
  end
end
