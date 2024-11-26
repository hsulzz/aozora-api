defmodule Aozora.Endpoint.Account do
  @moduledoc """
  ## API文档

  https://gmo-aozora.com/baas/api-cooperation/pdf/api-spec-corporate.pdf
  """
  alias Aozora.Endpoint
  alias Aozora.Endpoint.Account

  @account_path "#{Endpoint.base_path()}/accounts"
  @balance_path "#{@account_path}/balances"
  @transaction_path "#{@account_path}/transactions"
  @visa_transaction_path "#{@account_path}/visa-transactions"

  def account_path do
    @account_path
  end

  def balance_path do
    @balance_path
  end

  def transaction_path do
    @transaction_path
  end

  def visa_transaction_path do
    @visa_transaction_path
  end

  alias Aozora.Utils.FinchAdaptor, as: H

  require Logger

  @spec get() :: {:error, binary()} | {:ok, binary()}
  @doc """
  获取账户列表
  """
  def get do
    account_list_url =
      "https://#{Endpoint.api_host() <> Account.account_path()}"

    case H.get(account_list_url) do
      {:ok, body} -> {:ok, body}
      {:error, error} -> {:error, error}
    end
  end
end
