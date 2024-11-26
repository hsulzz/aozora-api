defmodule Aozora.Endpoint.Account.TransactionRegistry do
  @moduledoc false
  use GenServer

  require Logger
  # alias Aozora.Repo

  def start_link(opts) do
    Logger.debug("start supervising the transaction registry ")

    GenServer.start_link(
      __MODULE__,
      [],
      Keyword.merge(opts, name: __MODULE__)
    )
  end

  def init(opts) do
    {:ok, opts}
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def merge(data) do
    GenServer.call(__MODULE__, {:merge, data})
  end

  def flush do
    GenServer.call(__MODULE__, :flush)
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:merge, data}, _from, state) do
    new_state = data ++ state
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call(:flush, _from, _state) do
    {:reply, {:ok, []}, []}
  end
end
