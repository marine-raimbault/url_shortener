defmodule UrlShortener do
  def start do
    case :ets.whereis(:urls) do
      :undefined ->
        :ets.new(:urls, [:named_table, :set, :public])

      _ ->
        nil
    end
  end

  def shorten(long_url) do
    code = :crypto.strong_rand_bytes(4) |> Base.url_encode64() |> binary_part(0, 6)
    :ets.insert(:urls, {code, long_url})
    code
  end

  def expand(code) do
    case :ets.lookup(:urls, code) do
      [{^code, url}] -> {:ok, url}
      [] -> {:error, :not_found}
    end
  end
end
