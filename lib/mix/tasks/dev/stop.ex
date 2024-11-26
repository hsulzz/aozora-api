defmodule Mix.Tasks.Dev.Stop do
  @moduledoc false
  use Mix.Task
  require Logger
  @impl true
  def run(_) do
    # drop_db()
    stop_app()
  end

  # defp drop_db do
  #   Logger.debug("drop the database")
  #   Mix.Task.run("ecto.drop")
  # end

  defp stop_app do
    Logger.debug("stop the application")
    Mix.shell().cmd("docker-compose -f ./docker-compose.dev.yml down")
  end
end
