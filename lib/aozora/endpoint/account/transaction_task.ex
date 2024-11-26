defmodule Aozora.Endpoint.Account.TransactionTask do
  @moduledoc false
  use Task

  require Logger

  @one_miniute 1_000 * 60

  def start_link(_opts) do
    Task.start_link(__MODULE__, :update_transactions, [])
  end

  def update_transactions do
    case Aozora.Usecase.start() do
      {:ok, _} ->
        Logger.info("update transactions success")
    end

    :timer.sleep(@one_miniute * 10)

    update_transactions()
  end
end
