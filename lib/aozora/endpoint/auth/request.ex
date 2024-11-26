defmodule Aozora.Endpoint.Auth.Request do
  @moduledoc false
  @type t :: %__MODULE__{
          host: binary(),
          path: binary(),
          client_id: binary(),
          redirect_uri: binary(),
          response_type: binary(),
          scope: binary(),
          state: binary()
        }

  defstruct [:host, :path, :client_id, :redirect_uri, :response_type, :scope, :state]

  alias Aozora.Endpoint
  alias Aozora.Endpoint.Auth

  def request_fields(merge_fields \\ %{}) do
    %{
      host: Endpoint.api_host(),
      path: Auth.auth_path(),
      client_id: Endpoint.client_id(),
      redirect_uri: Endpoint.redirect_uri(),
      response_type: "code",
      scope: Endpoint.scope(),
      state: gen_state()
    }
    |> Map.merge(merge_fields)
  end

  def encode_url(%Auth.Request{} = req) do
    "https://#{req.host}#{req.path}?response_type=#{req.response_type}&scope=#{req.scope}&client_id=#{req.client_id}&state=#{req.state}&redirect_uri=#{req.redirect_uri}"
  end

  @spec gen_state() :: binary()
  def gen_state do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64()
  end
end
