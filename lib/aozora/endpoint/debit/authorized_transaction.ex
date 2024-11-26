defmodule Aozora.Endpoint.Debit.AuthorizedTransaction do
  @moduledoc """
  ## オーソリ電文明細照会API

  """
  require Logger
  alias Aozora.Endpoint
  alias Aozora.Endpoint.Debit
  alias Aozora.Utils.Datetime, as: D
  alias Aozora.Utils.FinchAdaptor, as: H
  # defstruct [:id, :account_id, :debit_card_id, :from_date, :to_date, :next_key]

  def get(
        account_id \\ "101011006224",
        debit_class \\ "1",
        from_date \\ nil,
        to_date \\ nil,
        next_key \\ nil
      )

  def get(account_id, debit_class, from_date, to_date, next_key)
      when from_date == nil or to_date == nil do
    from_date = D.n_weeks_ago_str(1)
    to_date = D.n_days_ago_str(2)
    get(account_id, debit_class, from_date, to_date, next_key)
  end

  def get(account_id, debit_class, from_date, to_date, next_key)
      when next_key == nil do
    url =
      "https://#{Endpoint.api_host() <> Debit.authorized_transaction_path()}?accountId=#{account_id}&requestDebitClass=#{debit_class}&dateFrom=#{from_date}&dateTo=#{to_date}"

    _get(url)
  end

  def get(account_id, debit_class, from_date, to_date, next_key) do
    url =
      "https://#{Endpoint.api_host() <> Debit.authorized_transaction_path()}?accountId=#{account_id}&requestDebitClass=#{debit_class}&dateFrom=#{from_date}&dateTo=#{to_date}&nextItemKey=#{next_key}"

    _get(url)
  end

  defp _get(url) do
    Logger.debug("url: #{url}")

    case H.get(url) do
      {:ok, body} -> {:ok, body}
      {:error, error} -> {:error, error}
    end
  end
end
