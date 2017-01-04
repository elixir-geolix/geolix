defmodule Geolix.Database.Loader do
  @moduledoc """
  Takes care of (re-) loading databases.
  """

  use GenServer

  alias Geolix.Database.Supervisor, as: DatabaseSupervisor


  # GenServer lifecycle

  @doc """
  Starts the database loader.
  """
  @spec start_link(list) :: GenServer.on_start
  def start_link(databases \\ []) do
    GenServer.start_link(__MODULE__, databases, name: __MODULE__)
  end

  def init(databases) do
    :ok   = GenServer.cast(__MODULE__, :reload_databases)
    state = Enum.map(databases, &({ Map.fetch!(&1, :id), &1 }))

    { :ok, state }
  end


  # GenServer callbacks

  def handle_call({ :get_database, which }, _, state) do
    { :reply, state[which], state }
  end

  def handle_call({ :load_database, database }, _, state) do
    case load_database(database) do
      :ok   -> { :reply, :ok, Keyword.put(state, database[:id], database) }
      error -> { :reply, error, state }
    end
  end

  def handle_call(:registered, _, state) do
    { :reply, Keyword.keys(state), state }
  end

  def handle_cast(:reload_databases, state) do
    :ok = state |> Keyword.values() |> Enum.each(&load_database/1)

    { :noreply, state }
  end


  # Internal methods

  defp load_database(%{ adapter: adapter } = database) do
    :ok = DatabaseSupervisor.start_adapter(adapter)

    case function_exported?(adapter, :load_database, 1) do
      true  -> adapter.load_database(database)
      false -> :ok
    end
  end
end
