defmodule Aozora.Endpoint.Token.TokenTask do
  @moduledoc false
  use Task

  alias Aozora.Endpoint.Token.TokenRegistry
  require Logger

  @one_hour 1_000 * 60 * 60
  # @one_day 1_000 * 60 * 60 * 24
  # @one_week @one_day * 7
  def start_link(_opts) do
    Task.start_link(__MODULE__, :update_token, [])
  end

  @spec update_token() :: :ok
  def update_token do
    :timer.sleep(@one_hour)

    case TokenRegistry.get() do
      {:ok, _} ->
        update_token()

      _ ->
        Logger.error("refresh token error, try reauth")

        TokenRegistry.reauth()
        |> case do
          {:ok, _} ->
            Logger.info("reauth success")
            update_token()

          _ ->
            Logger.error("reauth error, need admin check")
        end
    end
  end
end
