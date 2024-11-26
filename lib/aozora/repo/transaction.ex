defmodule Aozora.Repo.Transaction do
  use Ecto.Schema

  @moduledoc false
  # import Ecto.Changeset
  require Logger

  @type t :: %__MODULE__{
          management_no: String.t(),
          auth_code: String.t(),
          transaction_date: Date.t(),
          usage_details: String.t(),
          out_amount: integer,
          in_amount: integer,
          detail_no: String.t()
        }
  schema "gmo_transactions" do
    field(:management_no, :string)
    field(:auth_code, :string)
    field(:transaction_date, :date)
    field(:usage_details, :string)
    field(:out_amount, :integer)
    field(:in_amount, :integer)
    field(:detail_no, :string)
    timestamps()
  end

  alias Aozora.Repo

  def get_max_id do
    query =
      "SELECT TOP(1) MAX(id) as max_id, detail_no FROM gmo_transactions  GROUP BY detail_no ORDER BY max_id DESC "

    case Repo.query(query) do
      {:ok, result} ->
        Logger.debug("get_max_id: #{inspect(result)}")
        if result.rows == [], do: [], else: List.first(result.rows)

      _ ->
        nil
    end
  end
end
