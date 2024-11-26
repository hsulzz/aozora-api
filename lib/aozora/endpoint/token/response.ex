defmodule Aozora.Endpoint.Token.Response do
  @moduledoc false
  @type t :: %__MODULE__{
          access_token: binary(),
          refresh_token: binary(),
          expires_in: integer(),
          scope: binary(),
          token_type: binary()
        }
  require Logger

  alias Aozora.Endpoint.Token
  @derive Jason.Encoder
  defstruct [:access_token, :refresh_token, :expires_in, :scope, :token_type]

  @spec parse_json(binary()) :: {:ok, t()} | {:error, any()}
  def parse_json(json) do
    case Jason.decode(json, keys: :atoms) do
      {:ok, map} ->
        resp = struct(Token.Response, map)
        {:ok, resp}

      {:error, error} ->
        {:error, error}
    end
  end
end
