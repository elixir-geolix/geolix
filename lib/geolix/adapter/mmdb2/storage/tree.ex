defmodule Geolix.Adapter.MMDB2.Storage.Tree do
  @moduledoc """
  Geolix MMDB2 tree storage.

  ## Usage

      iex> set(:some_database_name, << 1, 2, 3 >>)
      :ok
      iex> get(:some_database_name)
      << 1, 2, 3 >>
      iex> get(:unregistered_database)
      nil
  """

  @name Geolix.Adapter.MMDB2.Names.storage(:tree)

  @doc """
  Starts the tree agent.
  """
  @spec start_link() :: Agent.on_start()
  def start_link(), do: Agent.start_link(fn -> %{} end, name: @name)

  @doc """
  Fetches the tree for a database.
  """
  @spec get(atom) :: binary | nil
  def get(database) do
    Agent.get(@name, &Map.get(&1, database, nil))
  end

  @doc """
  Stores the tree for a specific database.
  """
  @spec set(atom, binary | nil) :: :ok
  def set(database, tree) do
    Agent.update(@name, &Map.put(&1, database, tree))
  end
end
