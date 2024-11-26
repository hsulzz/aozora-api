defmodule Aozora.Utils.String do
  def mask(str) do
    String.duplicate("*", String.length(str))
  end
end
