defmodule Geolix.Database do
  use Bitwise, only_operators: true

  def lookup(_, nil) do
    nil
  end
  def lookup(ip, %{ cities: cities, countries: countries }) do
    %{ city:    lookup(ip, cities),
       country: lookup(ip, countries) }
  end
  def lookup(ip, database) do
    case parse_lookup_tree(ip, database.tree, database.meta) do
      0   -> nil
      ptr ->
        offset        = ptr - database.meta.node_count - 16
        { result, _ } = Geolix.Decoder.decode(database.data, offset)

        result
    end
  end

  def read_cities(db_dir) do
    case Geolix.Reader.read_cities(db_dir) do
      { :ok, data, meta } -> split_data(data, meta)
      { :error, reason }  -> { :error, reason }
    end
  end

  def read_countries(db_dir) do
    case Geolix.Reader.read_countries(db_dir) do
      { :ok, data, meta } -> split_data(data, meta)
      { :error, reason }  -> { :error, reason }
    end
  end

  def parse_lookup_tree(ip, tree, meta) do
    start_node = get_start_node(32, meta)

    parse_lookup_tree_bitwise(ip, 0, 32, start_node, tree, meta)
  end

  defp split_data(data, meta) do
    { meta, _ } = meta |> Geolix.Decoder.decode()

    meta = meta |> Enum.into( %{} )
    meta = meta |> Map.put(:node_byte_size, div(meta.record_size, 4))
    meta = meta |> Map.put(:tree_size, meta.node_count * meta.node_byte_size)

    tree = data |> binary_part(0, meta.tree_size)
    data = data |> binary_part(meta.tree_size + 16, size(data) - size(tree) - 16)

    { :ok, tree, data, meta }
  end

  defp parse_lookup_tree_bitwise(ip, bit, bit_count, node, tree, meta) when bit < bit_count do
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
        IO.puts "Invalid node below node_count: #{node}"
        0
    end
  end

  defp get_start_node(32, meta) do
    case meta.ip_version do
      6 -> 96
      _ -> 0
    end
  end
  defp get_start_node(_, _) do
    0
  end

  defp read_node(node, index, tree, meta) do
    offset = node * meta.node_byte_size
    size   = meta.record_size

    if 28 < size do
      IO.puts "Unhandled record_size '#{size}'!"
    end

    case size do
      24 -> tree |> binary_part(offset + index * 3, 3) |> decode_uint
      28 ->
        middle = tree
          |> binary_part(offset + 3, 1)
          |> :erlang.bitstring_to_list()
          |> hd()

        middle = 0xF0 &&& middle

        if 0 == index do
          middle = middle >>> 4
        end

        middle = middle |> List.wrap() |> :erlang.list_to_bitstring()
        bytes  = tree |> binary_part(offset + index * 4, 3)

        (middle <> bytes) |> decode_uint()
      _  -> 0
    end
  end

  defp decode_uint(bin) do
    bin
      |> :binary.bin_to_list()
      |> Enum.map( &(Integer.to_string(&1, 16)) )
      |> Enum.join()
      |> String.to_char_list()
      |> List.to_integer(16)
  end
end
