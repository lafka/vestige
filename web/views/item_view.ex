defmodule Vestige.ItemView do
  use Vestige.Views

  def format_date_time({{year, month, day}, {hour, minute, second}}) do
    :io_lib.format("~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0B~s",
        [year, month, day, hour, minute, second, tz])
      |> List.to_string
  end

  def tz do
    case Application.get_env :vestige, :timezone do
      nil ->
        {tz, 0} = System.cmd("date", ["+%z"])
        :ok = Application.put_env :vestige, :timezone, tz
        tz

      tz ->
        tz
    end
  end
end
