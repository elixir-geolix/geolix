defmodule Geolix.Adapter.MMDB2.Loader do
  @moduledoc """
  Loader module to load an MMDB2 database into Geolix.
  """

  alias Geolix.Adapter.MMDB2.Decoder
  alias Geolix.Adapter.MMDB2.Metadata
  alias Geolix.Adapter.MMDB2.Reader
  alias Geolix.Adapter.MMDB2.Storage


  @doc """
  Implementation of `Geolix.Adapter.MMDB2.load_database/1`.

  Requires the parameter `:source` as the location of the database. Can access
  the system environment by receiving a `{ :system, "env_var_name" }` tuple.
  """
  @spec load_database(map) :: :ok
  def load_database(%{ source: { :system, var }} = database) do
    database
    |> Map.put(:source, System.get_env(var))
    |> load_database()
  end

  def load_database(%{ id: id, source: source }) do
    source
    |> Reader.read_database()
    |> split_data()
    |> store_data(id)
  end


  defp split_data({ :error, _reason } = error), do: error
  defp split_data({ data, meta })               do
    meta           = Decoder.value(meta, 0)
    meta           = struct(%Metadata{}, meta)
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
  defp store_data({ tree, data, meta }, id)        do
    Storage.Data.set(id, data)
    Storage.Metadata.set(id, meta)
    Storage.Tree.set(id, tree)

    :ok
  end
end
