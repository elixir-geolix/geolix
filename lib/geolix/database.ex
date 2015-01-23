defmodule Geolix.Database do
  @moduledoc """
  Module to interact with the geo database.

  This includes proxy methods for reading the database and lookup up
  entries.
  """

  use Bitwise, only_operators: true

  require Logger

  alias Geolix.Storage

  @doc """
  Looks up information for the given ip in all databases.
  """
  @spec lookup(tuple) :: map
  def lookup(ip) do
    lookup_all(ip, Storage.Metadata.registered(), %{})
  end

  defp lookup_all(_, [], results), do: results
  defp lookup_all(ip, [ where | rest ], results) do
    result  = lookup(where, ip)
    results = Map.put(results, where, result)

    lookup_all(ip, rest, results)
  end

  @doc """
  Looks up information for the given ip in the given database.
  """
  @spec lookup(atom, tuple) :: nil | map
  def lookup(where, ip) do
    data = Storage.Data.get(where)
    meta = Storage.Metadata.get(where)
    tree = Storage.Tree.get(where)

    lookup(ip, data, meta, tree)
  end

  defp lookup(_, nil, _, _), do: nil
  defp lookup(_, _, nil, _), do: nil
  defp lookup(_, _, _, nil), do: nil
  defp lookup(ip, data, meta, tree) do
    parse_lookup_tree(ip, tree, meta)
    |> lookup_pointer(data, meta.node_count)
    |> maybe_include_ip(ip)
  end

  defp lookup_pointer(0, _, _), do: nil
  defp lookup_pointer(ptr, data, node_count) do
    offset = ptr - node_count - 16

    Geolix.Decoder.value(data, offset)
  end

  defp maybe_include_ip(nil, _ip),   do: nil
  defp maybe_include_ip(result, ip), do: Map.put(result, :ip, ip)

  @doc """
  Reads a database using `Geolix.Reader.read_database/1` and stores the
  parts in their respective storage agents.
  """
  @spec read_database(atom, String.t) :: :ok | { :error, term }
  def read_database(which, filename) do
    filename
    |> Geolix.Reader.read_database()
    |> split_data()
    |> store_data(which)
  end

  defp split_data({ :error, _reason } = error), do: error
  defp split_data({ data, meta }) do
    meta           = Geolix.Decoder.value(meta, 0)
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

  defp parse_lookup_tree(ip, tree, meta) do
    start_node = get_start_node(32, meta)

    parse_lookup_tree_bitwise(ip, 0, 32, start_node, tree, meta)
  end

  defp parse_lookup_tree_bitwise(ip, bit, bit_count, node, tree, meta)
      when bit < bit_count
  do
    if node >= meta.node_count do
      parse_lookup_tree_bitwise(nil, nil, nil, node, nil, meta)
    else
      temp_bit = 0xFF &&& elem(ip, bit >>> 3)
      node_bit = 1 &&& (temp_bit >>> 7 - rem(bit, 8))
      node     = read_node(node, node_bit, tree, meta)

      parse_lookup_tree_bitwise(ip, bit + 1, bit_count, node, tree, meta)
    end
  end
  defp parse_lookup_tree_bitwise(_, _, _, node, _, meta) do
    node_count = meta.node_count

    cond do
      node >  node_count -> node
      node == node_count -> 0
      true ->
        Logger.error "Invalid node below node_count: #{node}"
        0
    end
  end

  defp get_start_node(32, meta) do
    case meta.ip_version do
      6 -> 96
      _ -> 0
    end
  end

  defp read_node(node, index, tree, meta) do
    record_size = meta.record_size
    record_half = rem(record_size, 8)
    record_left = record_size - record_half

    node_start = div(node * record_size, 4)
    node_len   = div(record_size, 4)
    node_part  = binary_part(tree, node_start, node_len)

    << low   :: size(record_left),
       high  :: size(record_half),
       right :: size(record_size) >> = node_part

    case index do
      0 -> low + (high <<< record_left)
      1 -> right
    end
  end
end
