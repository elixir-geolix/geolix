defmodule Geolix.Benchmark do
  def run() do
    database =
      [Geolix.TestData.dir(:mmdb2), "Benchmark.mmdb"]
      |> Path.join()
      |> Path.expand()

    case File.exists?(database) do
      true ->
        Geolix.load_database(%{
          id: :benchmark,
          adapter: Geolix.Adapter.MMDB2,
          source: database
        })

        :ok = wait_for_database_loader()

        run_benchmark()

      false ->
        IO.warn("Expected database not found at #{database}")
    end
  end

  defp run_benchmark() do
    {:ok, lookup_ipv4} = :inet.parse_address('1.1.1.1')
    {:ok, lookup_ipv4_in_ipv6} = :inet.parse_address('::1.1.1.1')

    Benchee.run(
      %{
        "IPv4 in IPV6 lookup" => fn ->
          Geolix.lookup(lookup_ipv4_in_ipv6, where: :benchmark)
        end,
        "IPv4 lookup" => fn ->
          Geolix.lookup(lookup_ipv4, where: :benchmark)
        end
      },
      warmup: 2,
      time: 10
    )
  end

  defp wait_for_database_loader(), do: wait_for_database_loader(30_000)

  defp wait_for_database_loader(0) do
    IO.puts("Loading database took longer than 30 seconds. Aborting...")
    :error
  end

  defp wait_for_database_loader(timeout) do
    delay = 50
    loaded = Geolix.Database.Loader.loaded_databases()
    registered = Geolix.Database.Loader.registered_databases()

    if 0 < length(registered) && loaded == registered do
      :ok
    else
      :timer.sleep(delay)
      wait_for_database_loader(timeout - delay)
    end
  end
end

Geolix.Benchmark.run()
