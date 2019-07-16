defmodule Geolix.Adapter.Fake.Storage do
  @moduledoc false

  use Agent

  @doc false
  @spec start_link(map) :: Agent.on_start()
  def start_link(initial_value \\ %{}) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  @doc """
  Fetches the data for a database.
  """
  @spec get_data(atom) :: map | nil
  def get_data(database) do
    {data, _} = get(database)

    data
  end

  @doc """
  Fetches the metadata for a database.
  """
  @spec get_meta(atom) :: map | nil
  def get_meta(database) do
    {_, meta} = get(database)

    meta
  end

  @doc """
  Stores the data for a specific database.
  """
  @spec set(atom, {map | nil, map | nil}) :: :ok
  def set(database, dataset) do
    Agent.update(__MODULE__, &Map.put(&1, database, dataset))
  end

  defp get(database) do
    Agent.get(__MODULE__, &Map.get(&1, database, {%{}, %{}}))
  end
end
