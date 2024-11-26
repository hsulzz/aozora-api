defmodule Aozora.Endpoint.Auth do
  @moduledoc false
  @auth_path "/ganb/api/auth/v1/authorization"

  def auth_path do
    @auth_path
  end

  require Logger

  alias Aozora.Endpoint.Auth

  @doc """
  运行playwright脚本，完成认证，并获取code和state
  - code：第一次获取token时需要
  - state：用于验证请求，防止重放攻击
  """
  @spec code_and_state(Auth.Request.t()) :: {:ok, Auth.Response.t()} | {:error, binary()}
  def code_and_state(req) do
    env =
      with env <- System.get_env("MIX_ENV"),
           true <- is_nil(env) or env == "dev" or env == "test" do
        "dev"
      else
        _ ->
          "prod"
      end

    Logger.debug("start fetching the auth code via nodejs， ENV: #{env}")

    _ = System.cmd("npm", ["install"], cd: "src/playwright-node")

    {output, exit_code} =
      System.cmd("npm", ["run", env, Auth.Request.encode_url(req)], cd: "src/playwright-node")

    case exit_code do
      0 ->
        with {:ok, %Auth.Response{} = resp} <- filter_output(output),
             true <- validate_state(resp, req) do
          {:ok, resp}
        else
          _ ->
            {:error, "error"}
        end

      _ ->
        output
        |> Logger.error()

        {:error, "error"}
    end
  end

  # 验证state
  @spec validate_state(Auth.Response.t(), Auth.Request.t()) :: boolean()
  defp validate_state(%Auth.Response{} = resp, %Auth.Request{} = req) do
    case resp.state == req.state do
      true ->
        true

      false ->
        Logger.error("验证 state 不一致: #{inspect([resp.state, req.state])}")
        false
    end
  end

  alias Aozora.Utils.String, as: Str

  # 从nodejs输出中过滤出code和state
  @spec filter_output(binary()) :: {:ok, Auth.Response.t()} | {:error, String.t()}
  defp filter_output(output) when is_binary(output) do
    [code, state] =
      output
      |> String.split("\n", trim: true)
      |> List.last()
      |> String.split(" ")

    case code != "" && state != "" do
      true ->
        Logger.debug(
          "filtered output from nodejs: #{inspect([code |> Str.mask(), state |> Str.mask()])}"
        )

        {:ok, %Auth.Response{code: code, state: state}}

      false ->
        Logger.error("filtered output from nodejs: #{inspect([code, state])}")
        {:error, "error"}
    end
  end
end
