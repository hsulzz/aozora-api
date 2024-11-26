defmodule Aozora.Repo.Migrations.CreateGmoTransactions do
  use Ecto.Migration

  @doc """
  ## gmo_transactions 表

  | 序号  | 逻辑名   | 物理名           |     类型      | 说明        |
  | :---: | :------- | :--------------- | :-----------: | :---------- |
  |  01   | 管理番号 | management_no    | nvarchar(10)  | 借记卡ID    |
  |  02   | 承认番号 | auth_code        | nvarchar(10)  | 交易ID      |
  |  03   | 交易日期 | transaction_date |     date      | 交易日      |
  |  04   | 利用内容 | usage_details    | nvarchar(255) | 交易详情    |
  |  05   | 支出金額 | out_amount       |      int      |             |
  |  06   | 收入金額 | in_amount        |      int      |             |
  |  07   | 明细番号 | detail_no        |   timestamp   | 取自itemKey |

  """
  def change do
    create table(:gmo_transactions) do
      add(:management_no, :string, size: 10)
      add(:auth_code, :string, size: 10)
      add(:transaction_date, :date)
      add(:usage_details, :string)
      add(:out_amount, :integer)
      add(:in_amount, :integer)
      add(:detail_no, :string )
      timestamps()
    end

      create index(:gmo_transactions, [:detail_no], unique: true)
  end
end
