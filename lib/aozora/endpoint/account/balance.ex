defmodule Aozora.Endpoint.Account.Balance do
  @moduledoc false
  alias Aozora.Endpoint
  alias Aozora.Endpoint.Account
  alias Aozora.Utils.FinchAdaptor, as: H
  require Logger

  @spec get() :: {:error, binary()} | {:ok, binary()}
  @doc """
  获取账户余额
  """
  def get(account_id \\ "101011006224") do
    account_balance_url =
      "https://#{Endpoint.api_host() <> Account.balance_path()}?accountId=#{account_id}"

    case H.get(account_balance_url) do
      {:ok, body} -> {:ok, body}
      {:error, error} -> {:error, error}
    end
  end
end
