defmodule Aozora.Utils.Datetime do
  def n_days_ago_str(n \\ 0, timezone \\ "Asia/Tokyo") do
    Timex.now(timezone)
    |> Timex.to_date()
    |> Timex.shift(days: -n)
    |> Date.to_string()
  end

  def today_str(timezone \\ "Asia/Tokyo") do
    n_days_ago_str(0, timezone)
  end

  def n_weeks_ago_str(n, timezone \\ "Asia/Tokyo") when is_integer(n) do
    Timex.now(timezone)
    |> Timex.shift(days: -7 * n)
    |> Timex.to_date()
    |> Date.to_string()
  end
end
