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
    meta_data   = read_meta(meta_stream, [])
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

  defp read_meta(stream, meta_data) do
    ctrl_byte = Enum.take(stream, 1) |> hd()
    ctrl_code = :io_lib.format("~w", bitstring_to_list(ctrl_byte)) |> hd() |> list_to_integer()
    ctrl_type = Enum.at(@ctrl_types, ctrl_code >>> 5)

    read_size = get_meta_size(ctrl_code, stream)

    IO.puts inspect(ctrl_byte) <> " => " <> inspect(ctrl_type) <> " | size: " <> inspect(read_size)

    #decode_meta(stream, ctrl_type, read_size)
    read_meta(Enum.drop(stream, 1 + read_size), [])
  end

  defp get_meta_size(ctrl_code, stream) do
    # bitwise and with 0x1f
    case ctrl_code &&& 31 do
      _size when 29 == _size -> 29  + (Enum.take(stream, 2) |> tl() |> decode_uint32)
      _size when 30 == _size -> 285 + (Enum.take(stream, 3) |> tl() |> decode_uint32)
      _size when 31 == _size  ->
        IO.puts("multi byte")
        0
      _ -> ctrl_code &&& 31
    end
  end

  defp decode_uint32(bytes) do
    IO.inspect(bytes)
    0
  end
end
