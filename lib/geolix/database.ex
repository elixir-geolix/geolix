defmodule Geolix.Database do
  use Bitwise, only_operators: true

  @metadata_marker <<171, 205, 239>> <> "MaxMind.com"

  @ctrl_types [ :extended,  :pointer,    :utf8_string, :double,
                :bytes,     :uint16,     :uint32,      :map,
                :int32,     :uint32,     :uint128,     :array,
                :container, :end_marker, :boolean,     :float ]

  def read(db_dir) do
    cities    = read_cities(db_dir)
    countries = read_countries(db_dir)

    cond do
      is_list(cities) and is_list(countries) -> cities ++ countries
      is_tuple(cities)    -> cities
      is_tuple(countries) -> countries
      true -> { :error, "Unknown error" }
    end
  end

  defp read_cities(_) do
    []
  end

  defp read_countries(db_dir) do
    db_file    = db_dir <> "GeoLite2-Country.mmdb"
    db_file_gz = db_file <> ".gz"

    cond do
      File.regular?(db_file)    -> parse_countries({ :regular, db_file })
      File.regular?(db_file_gz) -> parse_countries({ :gzip , db_file_gz})
      true -> { :error, "Failed to find 'GeoLite2-Country.mmdb[.gz]' in given path '#{db_dir}'!" }
    end
  end

  defp parse_countries({ :regular, db_file }) do
    stream_countries(File.binstream!(db_file, [:read], 1))
  end
  defp parse_countries({ :gzip, db_file }) do
    stream_countries(File.binstream!(db_file, [:read, :compressed], 1))
  end

  defp stream_countries(stream) do
    meta_stream = drop_until_meta(stream)
    meta_data   = decode(meta_stream)

    IO.inspect(meta_data)
    []
  end

  defp drop_until_meta(stream) do
    stream = Enum.drop_while(stream, fn(c) -> c != String.at(@metadata_marker, 0) end)
    marker = Enum.take(stream, byte_size(@metadata_marker)) |> Enum.join()

    if marker == @metadata_marker do
      Enum.drop(stream, byte_size(@metadata_marker))
    else
      drop_until_meta(Enum.drop(stream, 1))
    end
  end

  defp decode(stream) do
    case Enum.take(stream, 1) do
      ctrl_byte when is_list(ctrl_byte) and 1 == length(ctrl_byte) ->
        ctrl_byte = hd(ctrl_byte)
        ctrl_code = :io_lib.format("~w", bitstring_to_list(ctrl_byte)) |> hd() |> list_to_integer()
        ctrl_type = Enum.at(@ctrl_types, ctrl_code >>> 5)

        { stream, read_size } = get_meta_size(Enum.drop(stream, 1), ctrl_code)

        decode_type(stream, ctrl_type, read_size)
      _ -> nil
    end
  end

  defp get_meta_size(stream, code) do
    # bitwise and with 0x1f
    case code &&& 31 do
      _size when 29 == _size ->
        { stream, size } = decode_uint32(stream, 1)
        { stream, 29 + size }
      _size when 30 == _size ->
        { stream, size } = decode_uint32(stream, 2)
        { stream, 285 + size }
      _ -> { stream, code &&& 31 }
    end
  end

  defp decode_type(stream, type, size) do
    case type do
      :double      -> decode_double(stream, size)
      :map         -> decode_map(stream, size)
      :utf8_string -> decode_utf8_string(stream, size)
      :uint16      -> decode_uint16(stream, size)
      _            -> { Enum.drop(stream, size), type }
    end
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

  defp decode_uint16(stream, size) do
    decode_uint32(stream, size)
  end

  defp decode_uint32(stream, size) when 0 < size do
    bytes  = Enum.take(stream, size) |> Enum.join()
    stream = Enum.drop(stream, size)

    uint   =  Enum.map(bitstring_to_list(bytes), fn(x) -> integer_to_binary(x, 16) end)
              |> Enum.join()
              |> String.to_char_list!()
              |> list_to_integer(16)

    { stream, uint }
  end
  defp decode_uint32(stream, 0) do
    { stream, 0 }
  end

  defp decode_utf8_string(stream, size) do
    string = Enum.take(stream, size) |> Enum.join()
    stream = Enum.drop(stream, size)

    { stream, string }
  end
end
