defmodule Geolix.Database do
  use Bitwise, only_operators: true

  @metadata_marker <<171, 205, 239>> <> "MaxMind.com"

  @ctrl_types [ :extended,  :pointer,    :utf8_string, :double,
                :bytes,     :uint16,     :uint32,      :map,
                :int32,     :uint64,     :uint128,     :array,
                :container, :end_marker, :boolean,     :float ]

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
    { _, metadata } = drop_until_meta(stream) |> decode()
    metadata        = HashDict.new(metadata)

    { metadata, [] }
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

  defp decode(stream) do
    case Enum.take(stream, 1) do
      ctrl_byte when is_list(ctrl_byte) and 1 == length(ctrl_byte) ->
        ctrl_code = hd(ctrl_byte) |> byte_to_code()
        ctrl_type = Enum.at(@ctrl_types, ctrl_code >>> 5)

        if :extended == ctrl_type do
          stream    = Enum.drop(stream, 1)
          ext_code  = Enum.take(stream, 1) |> hd() |> byte_to_code()
          ctrl_type = Enum.at(@ctrl_types, ext_code + 7)
        end

        { stream, read_size } = get_meta_size(Enum.drop(stream, 1), ctrl_code)

        decode_type(stream, ctrl_type, read_size)
      _ ->
        IO.puts("Invalid byte read from stream?!")
        { stream, nil }
    end
  end

  defp byte_to_code(byte) do
    :io_lib.format("~w", bitstring_to_list(byte))
        |> hd()
        |> list_to_integer()
  end

  defp get_meta_size(stream, code) do
    # bitwise and with 0x1f
    case code &&& 31 do
      _size when 29 == _size ->
        { stream, size } = decode_uint(stream, 1)
        { stream, 29 + size }
      _size when 30 == _size ->
        { stream, size } = decode_uint(stream, 2)
        { stream, 285 + size }
      _ -> { stream, code &&& 31 }
    end
  end

  defp decode_type(stream, type, size) do
    case type do
      :array       -> decode_array(stream, size)
      :double      -> decode_double(stream, size)
      :map         -> decode_map(stream, size)
      :utf8_string -> decode_utf8_string(stream, size)
      :uint16      -> decode_uint(stream, size)
      :uint32      -> decode_uint(stream, size)
      :uint64      -> decode_uint(stream, size)
      _ ->
        IO.puts "unhandled type #{type}: " <> inspect(Enum.take(stream, size))
        { Enum.drop(stream, size), type }
    end
  end

  defp decode_array(stream, size) do
    decode_array(stream, [], size)
  end

  defp decode_array(stream, arr, size) when 0 < size do
    { stream, elem } = decode(stream)

    decode_array(stream, arr ++ [elem], size - 1)
  end
  defp decode_array(stream, arr, 0) do
    { stream, arr }
  end

  defp decode_double(stream, size) do
    { Enum.drop(stream, size), :double }
  end

  defp decode_map(stream, size) do
    decode_map(stream, [], size)
  end

  defp decode_map(stream, map, size) when 0 < size do
    { stream, key } = decode(stream)
    { stream, val } = decode(stream)

    decode_map(stream, map ++ [{ key, val }], size - 1)
  end
  defp decode_map(stream, map, 0) do
    { stream, map }
  end

  defp decode_uint(stream, size) when 0 < size do
    bytes  = Enum.take(stream, size) |> Enum.join()
    stream = Enum.drop(stream, size)

    uint   =  Enum.map(bitstring_to_list(bytes), fn(x) -> integer_to_binary(x, 16) end)
              |> Enum.join()
              |> String.to_char_list!()
              |> list_to_integer(16)

    { stream, uint }
  end
  defp decode_uint(stream, 0) do
    { stream, 0 }
  end

  defp decode_utf8_string(stream, size) do
    string = Enum.take(stream, size) |> Enum.join()
    stream = Enum.drop(stream, size)

    { stream, string }
  end
end
