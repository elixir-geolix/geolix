defmodule Geolix.Database.Loader do
  @moduledoc """
  Takes care of (re-) loading databases.
  """

  use GenServer

  alias Geolix.Decoder
  alias Geolix.Reader
  alias Geolix.Storage

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

    { :ok, databases }
  end


  # GenServer callbacks

  def handle_call({ :set_database, which, filename }, _, state) do
    case load_database(which, filename) do
      :ok   -> { :reply, :ok, Keyword.put(state, which, filename) }
      error -> { :reply, error, state }
    end
  end


  # Internal methods

  defp init_databases([]), do: []
  defp init_databases([{ which, filename } | databases ]) do
    load_database(which, filename)
    init_databases(databases)
  end

  defp load_database(which, { :system, var }) do
    load_database(which, System.get_env(var))
  end

  defp load_database(which, filename) do
    filename
    |> Reader.read_database()
    |> split_data()
    |> store_data(which)
  end

  defp split_data({ :error, _reason } = error), do: error
  defp split_data({ data, meta }) do
    meta           = Decoder.value(meta, 0)
    meta           = struct(%Geolix.Metadata{}, meta)
    record_size    = Map.get(meta, :record_size)
    node_count     = Map.get(meta, :node_count)
    node_byte_size = div(record_size, 4)
    tree_size      = node_count * node_byte_size

    meta = %Geolix.Metadata{ meta | node_byte_size: node_byte_size }
    meta = %Geolix.Metadata{ meta | tree_size:      tree_size }

    tree      = data |> binary_part(0, tree_size)
    data_size = byte_size(data) - byte_size(tree) - 16
    data      = data |> binary_part(tree_size + 16, data_size)

    { tree, data, meta }
  end

  defp store_data({ :error, _reason } = error, _which), do: error
  defp store_data({ tree, data, meta }, which) do
    Storage.Data.set(which, data)
    Storage.Metadata.set(which, meta)
    Storage.Tree.set(which, tree)

    :ok
  end
end
