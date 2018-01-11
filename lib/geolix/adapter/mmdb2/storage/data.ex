defmodule Geolix.Adapter.MMDB2.Storage.Data do
  @moduledoc """
  Geolix MMDB2 data storage.

  ## Usage

      iex> set(:some_database_name, << 1, 2, 3 >>)
      :ok
      iex> get(:some_database_name)
      << 1, 2, 3 >>
      iex> get(:unregistered_database)
      nil
  """

  @name Geolix.Adapter.MMDB2.Names.storage(:data)

  @doc """
  Starts the data agent.
  """
  @spec start_link() :: Agent.on_start()
  def start_link(), do: Agent.start_link(fn -> %{} end, name: @name)

  @doc """
  Fetches the data for a database.
  """
  @spec get(atom) :: binary | nil
  def get(database) do
    Agent.get(@name, &Map.get(&1, database, nil))
  end

  @doc """
  Stores the data for a specific database.
  """
  @spec set(atom, binary | nil) :: :ok
  def set(database, data) do
    Agent.update(@name, &Map.put(&1, database, data))
  end
end
