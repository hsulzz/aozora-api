defmodule Aozora.Endpoint.Token.Request do
  @moduledoc false
  alias Aozora.Endpoint
  alias Aozora.Endpoint.{Auth, Token}

  require Logger

  @type t :: %__MODULE__{
          content_type: binary(),
          host: binary(),
          path: binary(),
          authorization: binary(),
          grant_type: binary(),
          code: binary(),
          redirect_uri: binary(),
          client_id: binary(),
          client_secret: binary(),
          refresh_token: binary()
        }
  defstruct [
    :content_type,
    :host,
    :path,
    :authorization,
    :grant_type,
    :code,
    :redirect_uri,
    :client_id,
    :client_secret,
    :refresh_token
  ]

  def request_fields(merge_fields \\ %{}) do
    %{
      content_type: "application/x-www-form-urlencoded",
      host: Endpoint.api_host(),
      path: Token.token_path(),
      authorization: authorization(Endpoint.client_id(), Endpoint.client_secret()),
      grant_type: "authorization_code",
      code: nil,
      redirect_uri: Endpoint.redirect_uri(),
      client_id: Endpoint.client_id(),
      client_secret: Endpoint.client_secret()
    }
    |> Map.merge(merge_fields)
  end

  @doc """
  首次获取token时调用，完成从 认证 到 获取token 等工作
  """
  @spec new_token() :: {:ok, Token.Response.t()} | {:error, binary()}
  def new_token do
    req = struct(Auth.Request) |> Map.merge(Auth.Request.request_fields())

    with {:ok, auth_resp} <- Auth.code_and_state(req),
         finch_req <- build_new_request(auth_resp),
         {:ok, %Finch.Response{status: 200, body: body}} <-
           Finch.request(finch_req, HttpClient),
         {:ok, token} <- Token.Response.parse_json(body) do
      {:ok, token}
    else
      {:error, error} ->
        Logger.error("Response: #{inspect(error)}")
        {:error, "error"}
    end
  end

  @spec refresh_token(Token.Response.t()) :: {:ok, Token.Response.t()} | {:error, binary()}
  def refresh_token(token_resp) do
    token_resp
    |> build_refresh_request()
    |> Finch.request(HttpClient)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        Token.Response.parse_json(body)

      {_, err} ->
        Logger.error("Response: #{inspect(err)}")
        {:error, "error"}
    end
  end

  @spec build_new_request(Auth.Response.t()) :: Finch.Request.t()
  defp build_new_request(%Auth.Response{code: code}) do
    req = struct(__MODULE__) |> Map.merge(request_fields()) |> Map.merge(%{code: code})

    Finch.build(
      :post,
      "https://#{req.host}#{req.path}",
      [{"Content-Type", req.content_type}, {"Authorization", req.authorization}],
      URI.encode_query(%{
        grant_type: req.grant_type,
        code: req.code,
        redirect_uri: req.redirect_uri,
        client_id: req.client_id,
        client_secret: req.client_secret
      })
    )
  end

  @spec build_refresh_request(Token.Response.t()) :: Finch.Request.t()
  defp build_refresh_request(%Token.Response{refresh_token: rt}) do
    req =
      struct(__MODULE__)
      |> Map.merge(Token.Request.request_fields())
      |> Map.merge(%{refresh_token: rt, grant_type: "refresh_token"})

    Finch.build(
      :post,
      "https://#{req.host}#{req.path}",
      [{"Content-Type", req.content_type}, {"Authorization", req.authorization}],
      URI.encode_query(%{
        grant_type: req.grant_type,
        refresh_token: req.refresh_token,
        client_id: req.client_id,
        client_secret: req.client_secret
      })
    )
  end

  defp authorization(client_id, client_secret) do
    "Basic " <> Base.encode64("#{client_id}:#{client_secret}")
  end
end
