import Config

# 数据库
config :aozora, Aozora.Repo,
  hostname: "localhost",
  username: "sa",
  password: "p@ssw0rd#mssql",
  database: "aozora_dev",
  port: 1433

# 代理信息
config :aozora,
  proxy_host: "example.com",
  proxy_port: 8888

alias Aozora.Endpoint

# API
config :aozora, Endpoint,
  api_host: "stg-api.gmo-aozora.com",
  client_id: "xxxxxxxxxxx",
  client_secret: "xxxxxx",
  redirect_uri: "https://xxxxx/auth",
  scope: "private:account private:debit-reference private:debit-transaction"

config :aozora, :logger, [
  {:handler, :file_log, :logger_std_h,
   %{
     config: %{
       file: ~c"aozora.log",
       filesync_repeat_interval: 5000,
       file_check: 5000,
       max_no_bytes: 10_000_000,
       max_no_files: 500,
       compress_on_rotate: true
     },
     formatter: Logger.Formatter.new()
   }}
]
