defmodule Geolix.Database.Loader do
  @moduledoc """
  Takes care of (re-) loading databases.
  """

  use GenServer

  require Logger

  alias Geolix.Database.Supervisor, as: DatabaseSupervisor

  @ets_state_name __MODULE__
  @ets_state_opts [:named_table, :protected, :set, read_concurrency: true]

  @doc false
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(state) do
    @ets_state_name = :ets.new(@ets_state_name, @ets_state_opts)

    :ok =
      :geolix
      |> Application.get_env(:databases, [])
      |> Enum.map(&preconfigure_database/1)
      |> Enum.filter(&Map.has_key?(&1, :id))
      |> Enum.each(&register_state(:registered, &1))

    :ok =
      case Application.get_env(:geolix, :startup_sync) do
        true -> reload_databases()
        _ -> GenServer.cast(__MODULE__, :reload_databases)
      end

    {:ok, state}
  end

  def handle_call({:load_database, db}, _, state) do
    db
    |> load_database()
    |> register_state(db)
    |> Map.get(:state)
    |> case do
      :loaded -> {:reply, :ok, state}
      :delayed -> {:reply, :delayed, state}
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
    :ok = reload_databases()

    {:noreply, state}
  end

  @doc """
  Returns state information for a specific database
  """
  @spec get_database(atom) :: map | nil
  def get_database(which) do
    case :ets.lookup(@ets_state_name, which) do
      [{^which, db}] -> db
      _ -> nil
    end
  rescue
    _ -> nil
  end

  @doc """
  Returns a list of all completely loaded databases.
  """
  @spec loaded_databases() :: [atom]
  def loaded_databases do
    @ets_state_name
    |> :ets.tab2list()
    |> Enum.filter(fn {_id, db} -> :loaded == Map.get(db, :state) end)
    |> Enum.map(fn {id, _db} -> id end)
  rescue
    _ -> []
  end

  @doc """
  Returns a list of all registered databases.

  Registered databases may or may not be already loaded.
  """
  @spec registered_databases() :: [atom]
  def registered_databases do
    @ets_state_name
    |> :ets.tab2list()
    |> Enum.map(fn {id, _db} -> id end)
  rescue
    _ -> []
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
  defp load_database(_), do: {:error, {:config, :missing_id}}

  defp load_error_message(:missing_adapter), do: "missing adapter configuration"
  defp load_error_message(:unknown_adapter), do: "unknown adapter configuration"

  defp maybe_log_error(%{id: id, state: {:error, {:config, reason}}} = db) do
    _ =
      Logger.error([
        "Failed to load database ",
        inspect(id),
        ": ",
        load_error_message(reason)
      ])

    db
  end

  defp maybe_log_error(db), do: db

  defp preconfigure_database(%{init: {mod, fun, extra_args}} = config) do
    apply(mod, fun, [config | extra_args])
  end

  defp preconfigure_database(%{init: {mod, fun}} = config) do
    apply(mod, fun, [config])
  end

  defp preconfigure_database(config), do: config

  defp register_state(:ok, db), do: register_state(:loaded, db)

  defp register_state(state, %{id: id} = db) do
    db = Map.put(db, :state, state)
    true = :ets.insert(@ets_state_name, {id, db})

    db
  end

  defp register_state(state, db), do: Map.put(db, :state, state)

  defp reload_databases do
    @ets_state_name
    |> :ets.tab2list()
    |> Enum.each(fn {_id, db} ->
      db
      |> load_database()
      |> register_state(db)
      |> maybe_log_error()
    end)
  end

  defp unload_database(%{adapter: adapter, id: id} = database) do
    if Code.ensure_loaded?(adapter) and function_exported?(adapter, :unload_database, 1) do
      :ok = adapter.unload_database(database)
    end

    true = :ets.delete(@ets_state_name, id)
    :ok
  end

  defp unload_database(%{id: id}) do
    true = :ets.delete(@ets_state_name, id)
    :ok
  end

  defp unload_database(_), do: :ok
end
