defmodule Mix.Tasks.Dev.Start do
  @moduledoc """
  Responsible for starting the dev environment.

  1. start the database docker container
  2. create the database
  3. start the application

  """
  require Logger
  use Mix.Task

  require IEx
  @impl true
  def run(_) do
    start_db()
    create_db()
    start_app()
  end

  defp start_db do
    Logger.debug("start the database")
    Mix.shell().cmd("docker-compose -f ./docker-compose.dev.yml up -d")
    :timer.sleep(10_000)
  end

  defp create_db do
    Logger.debug("create the database")
    Mix.Task.run("ecto.create")
    Mix.Task.run("ecto.migrate")
  end

  defp start_app do
    Logger.debug("start the application by command below \n => iex -S mix")
  end
end
