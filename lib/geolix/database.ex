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
    offset        = ptr - node_count - 16
    { result, _ } = Geolix.Decoder.decode(data, offset)

    result
  end

  defp maybe_include_ip(nil, _ip),   do: nil
  defp maybe_include_ip(result, ip), do: Map.put(result, :ip, ip)

  @doc """
  Reads a database using `Geolix.Reader.read_database/1` and stores the
  parts in their respective storage agents.
  """
  @spec read_database(atom, String.t) :: :ok
  def read_database(which, filename) do
    { tree, data, meta } =
         filename
      |> Geolix.Reader.read_database()
      |> split_data()

    Storage.Data.set(which, data)
    Storage.Metadata.set(which, meta)
    Storage.Tree.set(which, tree)

    :ok
  end

  defp parse_lookup_tree(ip, tree, meta) do
    start_node = get_start_node(32, meta)

    parse_lookup_tree_bitwise(ip, 0, 32, start_node, tree, meta)
  end

  defp split_data({ data, meta }) do
    { meta, _ } = meta |> Geolix.Decoder.decode()

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
    read_node_by_size(meta.record_size, tree, node * meta.node_byte_size, index)
  end

  defp read_node_by_size(24, tree, offset, index) do
    tree |> binary_part(offset + index * 3, 3) |> decode_uint
  end
  defp read_node_by_size(28, tree, offset, index) do
    middle =
         tree
      |> binary_part(offset + 3, 1)
      |> :erlang.bitstring_to_list()
      |> hd()

    middle = 0xF0 &&& middle

    if 0 == index do
      middle = middle >>> 4
    end

    middle = middle |> List.wrap() |> :erlang.list_to_bitstring()
    bytes  = tree |> binary_part(offset + index * 4, 3)

    decode_uint(middle <> bytes)
  end
  defp read_node_by_size(size, _, _, _) do
    Logger.error "Unhandled record_size '#{ size }'!"
    0
  end

  defp decode_uint(bin) do
    bin
      |> :binary.bin_to_list()
      |> Enum.map( &Integer.to_string(&1, 16) )
      |> Enum.join()
      |> String.to_char_list()
      |> List.to_integer(16)
  end
end
