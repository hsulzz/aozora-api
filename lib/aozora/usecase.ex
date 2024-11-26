defmodule Aozora.Usecase do
  @moduledoc false

  require Logger

  alias Aozora.Endpoint.Account.{Transaction, TransactionRegistry}
  alias Aozora.Repo
  alias Aozora.Utils.Datetime, as: D

  def start do
    list =
      case query_account_transactions_from_api() do
        {:ok, list} ->
          list

        {:error, err} ->
          Logger.error("failed to query account transactions #{err}")
          nil
      end

    case is_nil(list) do
      false ->
        translate_before_save(list)
        |> Enum.each(fn record -> Repo.insert(record) end)

        TransactionRegistry.flush()
        {:ok, "success"}

      true ->
        {:error, "failed to query account transactions"}
    end
  end

  @spec query_account_transactions_from_api() :: {:ok, list()} | {:error, binary()}
  defp query_account_transactions_from_api(
         account_id \\ "101011006224",
         from_date \\ D.n_days_ago_str(1),
         to_date \\ D.today_str(),
         next_key \\ nil
       ) do
    result =
      with {:ok, json} <- Transaction.get(account_id, from_date, to_date, next_key),
           {:ok, %{"hasNext" => has_next} = transactions} <-
             Jason.decode(json) do
        cache(transactions["transactions"])

        if has_next do
          Logger.info("has next: #{has_next}")
          query_account_transactions_from_api(from_date, to_date, transactions["next_key"])
        end
      else
        _ -> {:error, "failed to query account transactions"}
      end

    case result do
      {:error, error} ->
        Logger.error("failed to query account transactions: #{error}")
        {:error, error}

      _ ->
        {:ok, TransactionRegistry.get()}
    end
  end

  defp cache(transactions) do
    transactions |> TransactionRegistry.merge()
  end

  # 将api返回的数据转换成本地数据

  @spec translate_before_save(transactions :: list()) :: [Repo.Transaction.t()]
  def translate_before_save(transactions) do
    [_max_id, max_detail_no] =
      case Repo.Transaction.get_max_id() do
        [] ->
          [0, "0"]

        record ->
          record
      end

    transactions
    |> Enum.filter(fn t ->
      String.contains?(t["remarks"], "Visa") &&
        String.to_integer(t["itemKey"]) > String.to_integer(max_detail_no)
    end)
    |> Enum.map(fn t -> translate_one(t) end)
  end

  # api返回的数据 Transaction.Transactions["transactions"]
  # %{
  #   "amount" => "1007",
  #   "balance" => "1003114235",
  #   "itemKey" => "20241106100035205128",
  #   "remarks" => "	Visaデビット利用 GMOPG*MERCARI 承認番号：472998",
  #   "transactionDate" => "2024-11-06",
  #   "transactionType" => "2",
  #   "valueDate" => "2024-11-06"
  # }

  @spec translate_one(transaction :: map()) :: Repo.Transaction.t()
  defp translate_one(transaction) do
    # 日期信息
    transaction_date = transform_transaction_date(transaction["transactionDate"])

    # 交易信息
    trans_info =
      transform_transaction_amount(transaction["amount"], transaction["transactionType"])

    # 管理番号 承認番号
    {mgm_no, auth_code} = transform_remarks(transaction["remarks"])

    %Repo.Transaction{
      management_no: mgm_no,
      auth_code: auth_code,
      transaction_date: transaction_date,
      usage_details: transaction["remarks"],
      out_amount: trans_info[:out_amount],
      in_amount: trans_info[:in_amount],
      detail_no: transaction["itemKey"]
    }
  end

  defp transform_transaction_date(date) do
    case Date.from_iso8601(date) do
      {:ok, transaction_date} ->
        transaction_date

      _ ->
        Logger.error("failed to parse transaction_date: #{date}")
        nil
    end
  end

  # 出入金信息

  defp transform_transaction_amount(amount, transaction_type) do
    case transaction_type do
      # 入金
      "1" ->
        Map.merge(%{}, %{
          in_amount: amount |> String.to_integer(),
          out_amount: nil
        })

      # 出金
      "2" ->
        Map.merge(%{}, %{
          out_amount: amount |> String.to_integer(),
          in_amount: nil
        })
    end
  end

  # 管理番号 承认番号
  # eg:
  # ["Visaデビット利用", "GMOPG*MERCARI", "承認番号：532091"]
  # ["Visaデビット取消", "GMOPG*MERCARI", "承認番号：498829"]
  # ["Visaデビット利用", "0003", "GUCOLTD", "承認番号：494109"]
  @spec transform_remarks(remarks :: String.t()) ::
          {management_no :: String.t(), auth_code :: String.t()}

  defp transform_remarks(rmk) do
    remarks = String.trim(rmk) |> String.split(" ")

    case length(remarks) <= 2 do
      true ->
        {"9999", nil}

      _ ->
        [_ | [maybe_management_no | tail]] = remarks
        filtered_remarks = Enum.filter(tail, fn r -> String.contains?(r, "承認番号") end)

        mgn_no =
          if String.trim(maybe_management_no) |> String.starts_with?("00") do
            maybe_management_no
          else
            "9999"
          end

        case length(filtered_remarks) do
          0 ->
            {"9999", "nil"}

          _ ->
            auth_code = Enum.at(filtered_remarks, 0) |> String.trim()
            {mgn_no, auth_code}
        end
    end

  end
end
