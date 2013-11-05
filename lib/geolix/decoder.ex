defmodule Geolix.Decoder do
  @moduledoc """
  Decodes byte mddb2 format byte streams.
  """

  use Bitwise, only_operators: true

  @ctrl_types [ :extended,  :pointer,    :utf8_string, :double,
                :bytes,     :uint16,     :uint32,      :map,
                :int32,     :uint64,     :uint128,     :array,
                :container, :end_marker, :boolean,     :float ]

  @doc """
  Decodes the datatype found at the current position of the stream.
  """
  def decode(stream) do
    case Enum.take(stream, 1) do
      ctrl_byte when is_list(ctrl_byte) and 1 == length(ctrl_byte) ->
        ctrl_code = hd(ctrl_byte) |> byte_to_code()
        ctrl_type = Enum.at(@ctrl_types, ctrl_code >>> 5)

        decode_by_type(ctrl_type, ctrl_code, stream)
      _ ->
        IO.puts("Invalid byte read from stream?!")
        { stream, nil }
    end
  end

  defp decode_by_type(:array, ctrl_code, stream) do
    { stream, size } = stream |> Enum.drop(1) |> get_meta_size(ctrl_code)

    decode_array(stream, [], size)
  end

  defp decode_by_type(:extended, ctrl_code, stream) do
    stream    = Enum.drop(stream, 1)
    ext_code  = Enum.take(stream, 1) |> hd() |> byte_to_code()
    ctrl_type = Enum.at(@ctrl_types, ext_code + 7)

    decode_by_type(ctrl_type, ctrl_code, stream)
  end

  defp decode_by_type(:map, ctrl_code, stream) do
    { stream, size } = stream |> Enum.drop(1) |> get_meta_size(ctrl_code)

    decode_map(stream, [], size)
  end

  defp decode_by_type(:pointer, _, stream) do
    IO.puts("Pointers not handled yet!")
    { stream, nil }
  end

  defp decode_by_type(:uint16, ctrl_code, stream) do
    decode_by_type(:uint64, ctrl_code, stream)
  end
  defp decode_by_type(:uint32, ctrl_code, stream) do
    decode_by_type(:uint64, ctrl_code, stream)
  end
  defp decode_by_type(:uint64, ctrl_code, stream) do
    { stream, size } = stream |> Enum.drop(1) |> get_meta_size(ctrl_code)

    decode_uint(stream, size)
  end

  defp decode_by_type(:utf8_string, ctrl_code, stream) do
    { stream, size } = stream |> Enum.drop(1) |> get_meta_size(ctrl_code)

    decode_utf8_string(stream, size)
  end

  defp decode_by_type(ctrl_type, ctrl_code, stream) do
    IO.puts "unhandled type #{ctrl_type}: " <> inspect(Enum.take(stream, 16))

    { stream, size } = stream |> Enum.drop(1) |> get_meta_size(ctrl_code)
    { Enum.drop(stream, size), nil }
  end

  defp byte_to_code(byte) do
    :io_lib.format("~w", bitstring_to_list(byte))
      |> hd()
      |> list_to_integer()
  end

  defp get_meta_size(stream, code) do
    case code &&& 0x1f do
      _size when 29 == _size ->
        { stream, size } = decode_uint(stream, 1)
        { stream, 29 + size }
      _size when 30 == _size ->
        { stream, size } = decode_uint(stream, 2)
        { stream, 285 + size }
      _ -> { stream, code &&& 0x1f }
    end
  end

  defp decode_array(stream, arr, size) when 0 < size do
    { stream, elem } = stream |> decode()

    decode_array(stream, arr ++ [elem], size - 1)
  end
  defp decode_array(stream, arr, 0) do
    { stream, arr }
  end

  defp decode_map(stream, map, size) when 0 < size do
    { stream, key } = stream |> decode()
    { stream, val } = stream |> decode()

    decode_map(stream, map ++ [{ key, val }], size - 1)
  end
  defp decode_map(stream, map, 0) do
    { stream, map }
  end

  defp decode_uint(stream, size) when 0 < size do
    bytes  = stream |> Enum.take(size) |> Enum.join()
    stream = stream |> Enum.drop(size)

    uint = bitstring_to_list(bytes)
      |> Enum.map(fn(x) -> integer_to_binary(x, 16) end)
      |> Enum.join()
      |> String.to_char_list!()
      |> list_to_integer(16)

    { stream, uint }
  end
  defp decode_uint(stream, 0) do
    { stream, 0 }
  end

  defp decode_utf8_string(stream, size) do
    string = stream |> Enum.take(size) |> Enum.join()
    stream = stream |> Enum.drop(size)

    { stream, string }
  end
end
