defmodule Aozora.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :aozora,
    adapter: Ecto.Adapters.Tds
end
