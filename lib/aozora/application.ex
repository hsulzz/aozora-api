defmodule Aozora.Application do
  @moduledoc false
  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_handlers(:aozora)

    {proxy_host, proxy_port} = {
      Application.get_env(:aozora, :proxy_host) || "dev.lctjapan.com",
      Application.get_env(:aozora, :proxy_port) || 8888
    }

    alias Aozora.Endpoint.Token.{TokenRegistry, TokenTask}
    alias Aozora.Endpoint.Account.{TransactionRegistry, TransactionTask}

    children = [
      {Finch,
       name: HttpClient,
       pools: %{
         default: [
           protocols: [:http1],
           conn_opts: [
             proxy: {:http, proxy_host, proxy_port, []}
           ]
         ]
       }},
      TokenRegistry,
      TokenTask,
      TransactionRegistry,
      TransactionTask,
      Aozora.Repo
    ]

    opts = [strategy: :one_for_one, name: Aozora.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
