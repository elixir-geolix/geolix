defmodule Geolix.Database do
  use Bitwise, only_operators: true

  def read_cities(db_dir) do
    case Geolix.Reader.read_cities(db_dir) do
      { :ok, data, meta } -> test_read(data, meta)
      { :error, reason }  -> { :error, reason }
    end
  end

  def read_countries(db_dir) do
    case Geolix.Reader.read_countries(db_dir) do
      { :ok, data, meta } -> test_read(data, meta)
      { :error, reason }  -> { :error, reason }
    end
  end

  defp test_read(data, meta) do
    { meta, _ } = meta |> Geolix.Decoder.decode()

    meta = meta |> HashDict.new()
    meta = meta |> HashDict.put("node_byte_size", div(HashDict.fetch!(meta, "record_size"), 4))
    meta = meta |> HashDict.put("tree_size", HashDict.fetch!(meta, "node_count") * HashDict.fetch!(meta, "node_byte_size"))

    treesize = meta |> HashDict.fetch!("tree_size")

    tree = data |> binary_part(0, treesize)
    data = data |> binary_part(treesize + 16, size(data) - size(tree) - 16)

    #ip = {207,  97, 227, 245} # elixir-lang.org
    ip = {108, 168, 255, 243} # maxmind.com

    case parse_lookup_tree(ip, tree, meta) do
      0   -> { :ok, "Nothing found for: " <> inspect(ip) }
      ptr -> { :ok, Geolix.Decoder.decode(data, ptr - HashDict.fetch!(meta, "node_count") - 16) }
    end
  end

  defp parse_lookup_tree(ip, tree, meta) do
    start_node = get_start_node(32, meta)

    parse_lookup_tree_bitwise(ip, 0, 32, start_node, tree, meta)
  end

  defp parse_lookup_tree_bitwise(ip, bit, bit_count, node, tree, meta) when bit < bit_count do
    if node >= HashDict.fetch!(meta, "node_count") do
      parse_lookup_tree_bitwise(nil, nil, nil, node, nil, meta)
    else
      temp_bit = 0xFF &&& elem(ip, bit >>> 3)
      node_bit = 1 &&& (temp_bit >>> 7 - rem(bit, 8))
      node     = read_node(node, node_bit, tree, meta)

      parse_lookup_tree_bitwise(ip, bit + 1, bit_count, node, tree, meta)
    end
  end
  defp parse_lookup_tree_bitwise(_, _, _, node, _, meta) do
    node_count = HashDict.fetch!(meta, "node_count")

    cond do
      node >  node_count -> node
      node == node_count -> 0
      true ->
        IO.puts "Invalid node below node_count: #{node}"
        0
    end
  end

  defp get_start_node(32, meta) do
    case HashDict.fetch!(meta, "ip_version") do
      6 -> 96
      _ -> 0
    end
  end
  defp get_start_node(_, _) do
    0
  end

  defp read_node(node, index, tree, meta) do
    offset = node * HashDict.fetch!(meta, "node_byte_size")
    size   = HashDict.fetch!(meta, "record_size")

    if 24 < size do
      IO.puts "Unhandled record_size '#{size}'!"
    end

    case size do
      24 -> tree |> binary_part(offset + index * 3, 3) |> decode_uint
      _  -> 0
    end
  end

  defp decode_uint(bin) do
    bin
      |> :binary.bin_to_list()
      |> Enum.map(fn(x) -> integer_to_binary(x, 16) end)
      |> Enum.join()
      |> String.to_char_list!()
      |> list_to_integer(16)
  end
end
