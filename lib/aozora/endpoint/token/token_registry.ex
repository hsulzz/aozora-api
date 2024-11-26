defmodule Aozora.Endpoint.Token.TokenRegistry do
  use GenServer
  @moduledoc false
  require Logger
  alias Aozora.Endpoint.Token

  def start_link(opts) do
    Logger.debug("start supervising the token registry ")

    Token.Request.new_token()
    |> case do
      {:ok, resp} ->
        GenServer.start_link(__MODULE__, resp, Keyword.merge(opts, name: __MODULE__))

      _ ->
        Logger.error("failed to start the token registry")
        {:error, "error"}
    end
  end

  def init(opts) do
    {:ok, opts}
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def fetch_access_token do
    GenServer.call(__MODULE__, :fetch_access_token)
  end

  def refresh do
    GenServer.call(__MODULE__, :refresh)
  end

  @spec reauth() :: any()
  def reauth do
    Token.Request.new_token()
    |> case do
      {:ok, resp} -> GenServer.call(__MODULE__, {:reauth, resp})
      _ -> {:error, "error"}
    end
  end

  def handle_call(:get, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call(:fetch_access_token, _from, state) do
    {:reply, state.access_token, state}
  end

  def handle_call(:refresh, _from, state) do
    case Token.Request.refresh_token(state) do
      {:ok, new_state} -> {:reply, {:ok, new_state}, new_state}
      _ -> {:reply, {:error, "error"}, state}
    end
  end

  def handle_call({:reauth, resp}, _from, _state) do
    {:reply, {:ok, resp}, resp}
  end
end
