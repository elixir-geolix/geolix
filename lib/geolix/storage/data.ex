defmodule Geolix.Storage.Data do
  @moduledoc """
  Geolix data storage.

  ## Usage

      iex> set(:some_database_name, << 1, 2, 3 >>)
      :ok
      iex> get(:some_database_name)
      << 1, 2, 3 >>
      iex> get(:unregistered_database)
      nil
  """

  @doc """
  Starts the data agent.
  """
  @spec start_link() :: Agent.on_start
  def start_link(), do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  @doc """
  Fetches the data for a database.
  """
  @spec get(atom) :: binary | nil
  def get(database) do
    Agent.get(__MODULE__, &Map.get(&1, database, nil))
  end

  @doc """
  Stores the data for a specific database.
  """
  @spec set(atom, binary) :: :ok
  def set(database, data) do
    Agent.update(__MODULE__, &Map.put(&1, database, data))
  end
end
