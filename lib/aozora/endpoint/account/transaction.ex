defmodule Aozora.Endpoint.Account.Transaction do
  @moduledoc false
  require Logger

  alias Aozora.Endpoint
  alias Aozora.Endpoint.Account
  alias Aozora.Utils.Datetime, as: D
  alias Aozora.Utils.FinchAdaptor, as: H

  @spec get(
          account_id :: binary(),
          from_date :: binary() | nil,
          to_date :: binary() | nil,
          next_key :: binary() | nil
        ) :: {:error, binary()} | {:ok, binary()}

  @doc """
  获取账户交易记录
  """
  def get(
        account_id \\ "101011006224",
        from_date \\ nil,
        to_date \\ nil,
        next_key \\ nil
      )

  def get(account_id, from_date, to_date, next_key)
      when is_nil(from_date) or is_nil(to_date) do
    from_date = D.n_weeks_ago_str(1)
    to_date = D.today_str()

    get(account_id, from_date, to_date, next_key)
  end

  def get(account_id, from_date, to_date, next_key)
      when is_nil(next_key) or next_key == "" do
    account_transaction_url =
      "https://#{Endpoint.api_host() <> Account.transaction_path()}?accountId=#{account_id}&dateFrom=#{from_date}&dateTo=#{to_date}"

    _get(account_transaction_url)
  end

  def get(account_id, from_date, to_date, next_key) do
    account_transaction_url =
      "https://#{Endpoint.api_host() <> Account.transaction_path()}?accountId=#{account_id}&dateFrom=#{from_date}&dateTo=#{to_date}&nextItemKey=#{next_key}"

    _get(account_transaction_url)
  end

  defp _get(url) do
    case H.get(url) do
      {:ok, body} -> {:ok, body}
      {:error, error} -> {:error, error}
    end
  end
end
