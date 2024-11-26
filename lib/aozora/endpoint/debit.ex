defmodule Aozora.Endpoint.Debit do
  @moduledoc false
  alias Aozora.Endpoint

  @base_path "#{Endpoint.base_path()}/debit"
  @info_path "#{@base_path}/info"
  @transaction_path "#{@base_path}/transactions"
  @authorized_transaction_path "#{Endpoint.base_path()}/debit-transactions/authorized"
  @cleared_transaction_path "#{Endpoint.base_path()}/debit-transactions/cleared"

  def info_path do
    @info_path
  end

  def transaction_path do
    @transaction_path
  end

  def authorized_transaction_path do
    @authorized_transaction_path
  end

  def cleared_transaction_path do
    @cleared_transaction_path
  end
end
