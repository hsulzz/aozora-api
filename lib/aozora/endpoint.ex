defmodule Aozora.Endpoint do
  @moduledoc """

  # https://api.gmo-aozora.com/ganb/developer/api-docs/#/STOP0101
  """
  alias Aozora.Endpoint

  @base_path "/ganb/api/corporation/v1"

  @api_host Application.compile_env(:aozora, Endpoint)[:api_host] || "api_host"

  @client_id Application.compile_env(:aozora, Endpoint)[:client_id] || "client_id"

  @client_secret Application.compile_env(:aozora, Endpoint)[:client_secret] || "client_secret"

  @redirect_uri Application.compile_env(:aozora, Endpoint)[:redirect_uri] || "redirect_uri"

  @scope Application.compile_env(:aozora, Endpoint)[:scope] || "scope"

  @spec base_path() :: binary()
  def base_path do
    @base_path
  end

  @spec api_host() :: binary()
  def api_host do
    @api_host
  end

  @spec client_id() :: binary()
  def client_id do
    @client_id
  end

  @spec client_secret() :: binary()
  def client_secret do
    @client_secret
  end

  @spec redirect_uri() :: binary()
  def redirect_uri do
    @redirect_uri
  end

  @spec scope() :: binary()
  def scope do
    @scope
  end
end
