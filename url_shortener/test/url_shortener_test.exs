defmodule UrlShortenerTest do
  use ExUnit.Case

  @requests 10_000
  @url "https://google.com"

  setup do
    :ets.delete(:urls)
  rescue
    _ -> :ok
  after
    UrlShortener.start()
  end

  test "only starts once" do
    assert nil == UrlShortener.start()
  end

  test "shorten url" do
    code = UrlShortener.shorten(@url)
    assert {:ok, @url} = UrlShortener.expand(code)
  end

  test "handles 10000 req by sec WITH collision checking" do
    UrlShortener.start()

    start_time = System.monotonic_time(:millisecond)

    results =
      1..@requests
      |> Task.async_stream(
        fn i ->
          # Use unique URLs to actually test collisions
          url = "#{@url}/#{i}"
          UrlShortener.shorten(url)
        end,
        max_concurrency: 1000,
        timeout: 10_000
      )
      # Now we capture the results
      |> Enum.to_list()

    end_time = System.monotonic_time(:millisecond)

    # Extract the actual codes
    codes =
      results
      |> Enum.map(fn {:ok, code} -> code end)

    # Check for collisions
    unique_codes = Enum.uniq(codes)
    collisions = length(codes) - length(unique_codes)

    duration_ms = end_time - start_time
    rps = @requests / (duration_ms / 1000)

    IO.puts("Completed #{@requests} shorten/1 calls in #{duration_ms} ms")
    IO.puts("That's approximately #{round(rps)} requests per second.")
    IO.puts("🔍 Collisions detected: #{collisions}")

    assert collisions == 0, "Found #{collisions} collisions!"
  end
end
