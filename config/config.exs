import Config

config :aozora, ecto_repos: [Aozora.Repo]

import_config "#{config_env()}.exs"
