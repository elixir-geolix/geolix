defmodule Geolix.Database.Loader do
  @moduledoc """
  Takes care of (re-) loading databases.
  """

  use GenServer

  # GenServer lifecycle

  @doc """
  Starts the database loader.
  """
  @spec start_link(list) :: GenServer.on_start
  def start_link(databases \\ []) do
    GenServer.start_link(__MODULE__, databases, name: __MODULE__)
  end

  def init(databases) do
    init_databases(databases)

    state =
      databases
      |> Enum.map(&fix_legacy/1)
      |> Enum.map(fn (database) -> { database[:id], database } end)

    { :ok, state }
  end


  # GenServer callbacks

  def handle_call({ :load_database, database }, _, state) do
    case load_database(database) do
      :ok   -> { :reply, :ok, Keyword.put(state, database[:id], database) }
      error -> { :reply, error, state }
    end
  end

  def handle_call({ :set_database, which, filename }, from, state) do
    database = fix_legacy({ which, filename })

    handle_call({ :load_database, database }, from, state)
  end

  def handle_call(:registered, _, state) do
    { :reply, Keyword.keys(state), state }
  end


  # Internal methods

  defp fix_legacy(database) when is_map(database), do: database
  defp fix_legacy({ which, filename }) do
    IO.write :stderr, "The database '#{ inspect which }' is loaded using" <>
                      " a deprecated tuple definition. Please update to" <>
                      " the new map based format."

    %{
      id:      which,
      adapter: Geolix.Adapter.MMDB2,
      source:  filename
    }
  end


  defp init_databases([]), do: []
  defp init_databases([ database | databases ]) do
    database
    |> fix_legacy()
    |> load_database()

    init_databases(databases)
  end

  defp load_database(%{ source: { :system, var }} = database) do
    database
    |> Map.put(:source, System.get_env(var))
    |> load_database()
  end

  defp load_database(%{ source: source, adapter: adapter } = database) do
    reader = Module.concat([ adapter, Reader ])

    source
    |> reader.read_database()
    |> split_data(database)
    |> store_data(database)
  end


  defp split_data({ :error, _reason } = error, _), do: error
  defp split_data({ data, meta }, %{ adapter: adapter }) do
    decoder    = Module.concat([ adapter, Decoder ])
    metastruct = Module.concat([ adapter, Metadata ])

    meta           = decoder.value(meta, 0)
    meta           = struct(metastruct, meta)
    record_size    = Map.get(meta, :record_size)
    node_count     = Map.get(meta, :node_count)
    node_byte_size = div(record_size, 4)
    tree_size      = node_count * node_byte_size

    meta = %{ meta | node_byte_size: node_byte_size }
    meta = %{ meta | tree_size:      tree_size }

    tree      = data |> binary_part(0, tree_size)
    data_size = byte_size(data) - byte_size(tree) - 16
    data      = data |> binary_part(tree_size + 16, data_size)

    { tree, data, meta }
  end

  defp store_data({ :error, _reason } = error, _), do: error
  defp store_data({ tree, data, meta }, %{ id: id, adapter: adapter}) do
    storage_data = Module.concat([ adapter, Storage.Data ])
    storage_meta = Module.concat([ adapter, Storage.Metadata ])
    storage_tree = Module.concat([ adapter, Storage.Tree ])

    storage_data.set(id, data)
    storage_meta.set(id, meta)
    storage_tree.set(id, tree)

    :ok
  end
end
