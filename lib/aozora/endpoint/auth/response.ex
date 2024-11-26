defmodule Aozora.Endpoint.Auth.Response do
  @moduledoc false
  @type t :: %__MODULE__{
          code: binary(),
          state: binary()
        }
  defstruct [:code, :state]

  def parse_resp([code, state] = _resp) do
    struct(__MODULE__, code: code, state: state)
  end
end
