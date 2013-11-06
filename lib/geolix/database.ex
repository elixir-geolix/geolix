defmodule Geolix.Database do
  use Bitwise, only_operators: true

  @metadata_marker <<171, 205, 239>> <> "MaxMind.com"

  @doc """
  Returns city data from file found in directory.
  """
  def read_cities(db_dir) do
    db_file    = db_dir <> "GeoLite2-City.mmdb"
    db_file_gz = db_file <> ".gz"

    cond do
      File.regular?(db_file)    -> parse_file({ :regular, db_file })
      File.regular?(db_file_gz) -> parse_file({ :gzip , db_file_gz})
      true -> { :error, "Failed to find 'GeoLite2-City.mmdb[.gz]' in given path '#{db_dir}' !" }
    end
  end

  @doc """
  Returns country data from file found in directory.
  """
  def read_countries(db_dir) do
    db_file    = db_dir <> "GeoLite2-Country.mmdb"
    db_file_gz = db_file <> ".gz"

    cond do
      File.regular?(db_file)    -> parse_file({ :regular, db_file })
      File.regular?(db_file_gz) -> parse_file({ :gzip , db_file_gz})
      true -> { :error, "Failed to find 'GeoLite2-Country.mmdb[.gz]' in given path '#{db_dir}' !" }
    end
  end

  defp parse_file({ :regular, db_file }) do
    File.binstream!(db_file, [:read], 1) |> parse_stream()
  end
  defp parse_file({ :gzip, db_file }) do
    File.binstream!(db_file, [:read, :compressed], 1) |> parse_stream()
  end

  defp parse_stream(stream) do
    { metadata, _ } = drop_until_meta(stream) |> Geolix.Decoder.decode()
    metadata        = HashDict.new(metadata)
    metadata        = HashDict.put(metadata, "node_byte_size", div(HashDict.fetch!(metadata, "record_size"), 4))
    metadata        = HashDict.put(
      metadata, "search_tree_size",
      HashDict.fetch!(metadata, "node_count") * HashDict.fetch!(metadata, "node_byte_size"))

    #ip = {207,  97, 227, 245} # elixir-lang.org
    ip = {108, 168, 255, 243} # maxmind.com

    case parse_lookup_tree(ip, stream, metadata) do
      0   -> IO.puts "Nothing found!"
      ptr ->
        ptr = ptr - HashDict.fetch!(metadata, "node_count") - 16
        IO.puts "ptr: #{ptr} => " <> inspect(stream |> drop_until_data(metadata) |> Geolix.Decoder.decode(ptr))
    end

    { metadata, nil }
  end

  defp parse_lookup_tree(ip, stream, metadata) do
    start_node = 96
    #start_node = get_start_node(32, metadata, stream)

    parse_lookup_tree_bitwise(ip, 0, 32, start_node, stream, metadata)
  end

  defp parse_lookup_tree_bitwise(ip, bit, bit_count, node, stream, metadata) when bit < bit_count do
    if node >= HashDict.fetch!(metadata, "node_count") do
      parse_lookup_tree_bitwise(nil, nil, nil, node, nil, metadata)
    else
      temp_bit = 0xFF &&& elem(ip, bit >>> 3)
      node_bit = 1 &&& (temp_bit >>> 7 - rem(bit, 8))
      node     = read_node(node, node_bit, stream, metadata)

      parse_lookup_tree_bitwise(ip, bit + 1, bit_count, node, stream, metadata)
    end
  end
  defp parse_lookup_tree_bitwise(_, _, _, node, _, metadata) do
    node_count = HashDict.fetch!(metadata, "node_count")

    cond do
      node >  node_count -> node
      node == node_count -> 0
      true ->
        IO.puts "Invalid node below node_count: #{node}"
        0
    end
  end

  defp drop_until_meta(stream) do
    stream = Enum.drop_while(stream, fn(c) -> c != String.at(@metadata_marker, 0) end)
    marker = Enum.take(stream, byte_size(@metadata_marker)) |> Enum.join()

    if marker == @metadata_marker do
      Enum.drop(stream, byte_size(@metadata_marker))
    else
      Enum.drop(stream, 1) |> drop_until_meta()
    end
  end

  defp drop_until_data(stream, metadata) do
    stream |> Enum.drop(HashDict.fetch!(metadata, "search_tree_size")) |> Enum.drop(16)
  end

  defp get_start_node(32, metadata, stream) do
    case HashDict.fetch!(metadata, "ip_version") do
      6 -> get_start_node_ipv4(0, 0, stream, metadata)
      _ -> 0
    end
  end
  defp get_start_node(_, _, _) do
    0
  end

  defp get_start_node_ipv4(node, 96, _, _) do
    node
  end
  defp get_start_node_ipv4(node, index, stream, metadata) do
    read_node(node, 0, stream, metadata)
      |> get_start_node_ipv4(index + 1, stream, metadata)
  end

  defp read_node(node, index, stream, metadata) do
    IO.puts "Reading node: #{node} (index: #{index})"

    offset = node * HashDict.fetch!(metadata, "node_byte_size")

    case HashDict.fetch!(metadata, "record_size") do
      24 ->
        stream
          |> Enum.drop(offset + index * 3)
          |> Enum.take(3)
          |> Enum.join()
          |> decode_uint
      invalid ->
        IO.puts("Invalid record size in metadata: #{invalid}")
        0
    end
  end

  defp decode_uint(bytes) do
    bitstring_to_list(bytes)
      |> Enum.map(fn(x) -> integer_to_binary(x, 16) end)
      |> Enum.join()
      |> String.to_char_list!()
      |> list_to_integer(16)
  end
end
