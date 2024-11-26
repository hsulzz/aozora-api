defmodule Aozora.Utils.FinchAdaptor do
  alias Aozora.Endpoint.Token.TokenRegistry, as: T
  require Logger

  @spec get(binary() | URI.t()) :: {:error, <<_::40>>} | {:ok, binary()}
  def get(url, headers \\ [], client \\ HttpClient)

  def get(url, headers, client) do
    default_headers = [{"x-access-token", T.fetch_access_token()}, {"Accept", "application/json"}]

    Finch.build(
      :get,
      url,
      headers ++ default_headers
    )
    |> Finch.request(client)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, body}

      {_, err} ->
        Logger.error("Response: #{inspect(err)}")
        {:error, "error"}
    end
  end
end
