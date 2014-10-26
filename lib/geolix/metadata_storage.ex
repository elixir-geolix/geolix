defmodule Geolix.MetadataStorage do
  @moduledoc """
  Geolix metadata storage.

  ## Usage

      iex> set(:some_database_name, %Geolix.Metadata{})
      :ok
      iex> get(:some_database_name)
      %Geolix.Metadata{}
      iex> get("unregistered-database")
      nil
  """

  alias Geolix.Metadata

  @doc """
  Starts the metadata agent.
  """
  @spec start_link() :: Agent.on_start
  def start_link(), do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  @doc """
  Fetches a metadata entry for a database.
  """
  @spec get(atom) :: Metadata.t | nil
  def get(database) do
    Agent.get(__MODULE__, &Map.get(&1, database, nil))
  end

  @doc """
  Stores a set of metadata for a specific database.
  """
  @spec set(atom, Metadata.t) :: :ok
  def set(database, %Metadata{} = metadata) do
    Agent.update(__MODULE__, &Map.put(&1, database, metadata))
  end
end
