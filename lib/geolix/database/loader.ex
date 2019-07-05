defmodule Geolix.Database.Loader do
  @moduledoc """
  Takes care of (re-) loading databases.
  """

  use GenServer

  require Logger

  alias Geolix.Database.Supervisor, as: DatabaseSupervisor

  @ets_state_name :geolix_database_loader
  @ets_state_opts [:named_table, :protected, :set, read_concurrency: true]

  @doc false
  def start_link(databases \\ []) do
    GenServer.start_link(__MODULE__, databases, name: __MODULE__)
  end

  def init(databases) do
    @ets_state_name = :ets.new(@ets_state_name, @ets_state_opts)

    :ok =
      databases
      |> Enum.filter(&Map.has_key?(&1, :id))
      |> Enum.each(&register_state(:registered, &1))

    :ok = GenServer.cast(__MODULE__, :reload_databases)

    {:ok, nil}
  end

  def handle_call({:load_database, db}, _, state) do
    db
    |> load_database()
    |> register_state(db)
    |> Map.get(:state)
    |> case do
      :loaded -> {:reply, :ok, state}
      {:error, _} = err -> {:reply, err, state}
    end
  end

  def handle_call({:unload_database, which}, _, state) do
    result =
      which
      |> get_database()
      |> unload_database()

    {:reply, result, state}
  end

  def handle_cast(:reload_databases, state) do
    @ets_state_name
    |> :ets.tab2list()
    |> Enum.each(fn {_id, db} ->
      db
      |> load_database()
      |> register_state(db)
      |> maybe_log_error()
    end)

    {:noreply, state}
  end

  @doc """
  Returns state information for a specific database
  """
  @spec get_database(atom) :: map | nil
  def get_database(which) do
    case :ets.info(@ets_state_name) do
      :undefined ->
        nil

      _ ->
        case :ets.lookup(@ets_state_name, which) do
          [{^which, db}] -> db
          _ -> nil
        end
    end
  end

  @doc """
  Returns a list of all completely loaded databases.
  """
  @spec loaded_databases() :: [atom]
  def loaded_databases do
    case :ets.info(@ets_state_name) do
      :undefined ->
        []

      _ ->
        @ets_state_name
        |> :ets.tab2list()
        |> Enum.filter(fn {_id, db} -> :loaded == Map.get(db, :state) end)
        |> Enum.map(fn {id, _db} -> id end)
    end
  end

  @doc """
  Returns a list of all registered databases.

  Registered databases may or may not be already loaded.
  """
  @spec registered_databases() :: [atom]
  def registered_databases do
    case :ets.info(@ets_state_name) do
      :undefined ->
        []

      _ ->
        @ets_state_name
        |> :ets.tab2list()
        |> Enum.map(fn {id, _db} -> id end)
    end
  end

  defp load_database(%{adapter: adapter} = database) do
    if Code.ensure_loaded?(adapter) do
      :ok = DatabaseSupervisor.start_database(database)

      if function_exported?(adapter, :load_database, 1) do
        adapter.load_database(database)
      else
        :ok
      end
    else
      {:error, {:config, :unknown_adapter}}
    end
  end

  defp load_database(%{id: _}), do: {:error, {:config, :missing_adapter}}
  defp load_database(_), do: {:error, {:config, :invalid}}

  defp load_error_message(:missing_adapter), do: "missing adapter configuration"
  defp load_error_message(:unknown_adapter), do: "unknown adapter configuration"
  defp load_error_message(reason), do: reason

  defp maybe_log_error(%{id: id, state: {:error, {:config, reason}}} = db) do
    _ =
      Logger.error(fn ->
        "Failed to load database #{id}: #{load_error_message(reason)}"
      end)

    db
  end

  defp maybe_log_error(db), do: db

  defp register_state(:ok, db), do: register_state(:loaded, db)

  defp register_state(state, %{id: id} = db) do
    db = Map.put(db, :state, state)
    true = :ets.insert(@ets_state_name, {id, db})

    db
  end

  defp unload_database(nil), do: :ok

  defp unload_database(%{adapter: adapter, id: id} = database) do
    if Code.ensure_loaded?(adapter) and function_exported?(adapter, :unload_database, 1) do
      adapter.unload_database(database)
    end

    true = :ets.delete(@ets_state_name, id)

    :ok
  end
end
