defmodule Geolix.Server.Worker do
  @moduledoc false

  alias Geolix.Database.Loader

  use GenServer

  @behaviour :poolboy_worker

  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(state), do: {:ok, state}

  def handle_call({:lookup, ip, opts}, _, state) do
    case opts[:where] do
      nil -> {:reply, lookup_all(ip, opts), state}
      where -> {:reply, lookup_single(ip, opts, where), state}
    end
  end

  def handle_call({:metadata, opts}, _, state) do
    case opts[:where] do
      nil -> {:reply, metadata_all(), state}
      where -> {:reply, metadata_single(where), state}
    end
  end

  defp lookup_all(ip, opts) do
    lookup_all(ip, opts, Loader.loaded_databases())
  end

  defp lookup_all(_, _, []), do: %{}

  defp lookup_all(ip, opts, databases) do
    databases
    |> Task.async_stream(
      fn database ->
        {database, lookup_single(ip, opts, database)}
      end,
      ordered: false
    )
    |> Enum.into(%{}, fn {:ok, result} -> result end)
  end

  defp lookup_single(ip, opts, where) do
    case Loader.get_database(where) do
      nil -> nil
      %{adapter: adapter} = database -> adapter.lookup(ip, opts, database)
    end
  end

  defp metadata_all do
    metadata_all(Loader.loaded_databases())
  end

  defp metadata_all(databases) do
    databases
    |> Task.async_stream(
      fn database ->
        {database, metadata_single(database)}
      end,
      ordered: false
    )
    |> Enum.into(%{}, fn {:ok, result} -> result end)
  end

  defp metadata_single(where) do
    case Loader.get_database(where) do
      nil -> nil
      %{adapter: adapter} = database -> adapter.metadata(database)
    end
  end
end
