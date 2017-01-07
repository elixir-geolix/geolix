defmodule Geolix.Adapter.Fake.Storage do
  @moduledoc """
  Fake adapter storage agent.
  """

  @doc """
  Starts the storage adapter.
  """
  @spec start_link() :: Agent.on_start()
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Fetches the data for a database.
  """
  @spec get(atom) :: map | nil
  def get(database) do
    Agent.get(__MODULE__, &Map.get(&1, database, nil))
  end

  @doc """
  Stores the data for a specific database.
  """
  @spec set(atom, map) :: :ok
  def set(database, data) do
    Agent.update(__MODULE__, &Map.put(&1, database, data))
  end
end
