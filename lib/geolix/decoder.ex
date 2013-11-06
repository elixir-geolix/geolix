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
  Decodes the datatype found at the start of the stream.
  """
  def decode(stream) do
    decode(stream, 0)
  end

  @doc """
  Decodes the datatype found at the given offset of the stream.
  """
  def decode(stream, offset) do
    mod_stream = stream |> Enum.drop(offset)

    case Enum.take(mod_stream, 1) do
      ctrl_byte when is_list(ctrl_byte) and 1 == length(ctrl_byte) ->
        ctrl_code = hd(ctrl_byte) |> byte_to_code()
        ctrl_type = Enum.at(@ctrl_types, ctrl_code >>> 5)

        decode_by_type(ctrl_type, ctrl_code, stream, 1 + offset)
      _ ->
        IO.puts("Invalid byte read from stream?!")
        { nil, offset }
    end
  end

  defp decode_by_type(:array, ctrl_code, stream, offset) do
    { size, offset } = ctrl_code |> get_meta_size(stream, offset)

    decode_array([], size, stream, offset)
  end
  defp decode_by_type(:extended, ctrl_code, stream, offset) do
    mod_stream = stream |> Enum.drop(offset)
    ext_code   = mod_stream |> Enum.take(1) |> hd() |> byte_to_code()
    ctrl_type  = Enum.at(@ctrl_types, ext_code + 7)

    decode_by_type(ctrl_type, ctrl_code, stream, 1 + offset)
  end
  defp decode_by_type(:map, ctrl_code, stream, offset) do
    { size, offset } = ctrl_code |> get_meta_size(stream, offset)

    decode_map([], size, stream, offset)
  end
  defp decode_by_type(:pointer, ctrl_code, stream, offset) do
    size   = ((ctrl_code >>> 3) &&& 0x3) + 1
    buffer = stream |> Enum.drop(offset) |> Enum.take(size)

    if 4 > size do
      buffer = [<<ctrl_code &&& 0x7>>] ++ buffer
    end

    pointer =
      buffer
      |> Enum.join()
      |> bitstring_to_list()
      |> Enum.map(fn(x) -> integer_to_binary(x, 16) end)
      |> Enum.join()
      |> String.to_char_list!()
      |> list_to_integer(16)

    case size do
      2 -> pointer = pointer + 2048
      3 -> pointer = pointer + 526336
      _ -> nil
    end

    { data, _ } = decode(stream, pointer)
    { data, offset + size }
  end
  defp decode_by_type(:uint16, ctrl_code, stream, offset) do
    decode_by_type(:uint64, ctrl_code, stream, offset)
  end
  defp decode_by_type(:uint32, ctrl_code, stream, offset) do
    decode_by_type(:uint64, ctrl_code, stream, offset)
  end
  defp decode_by_type(:uint64, ctrl_code, stream, offset) do
    { size, offset } = ctrl_code |> get_meta_size(stream, offset)

    decode_uint(size, stream, offset)
  end
  defp decode_by_type(:utf8_string, ctrl_code, stream, offset) do
    { size, offset } = ctrl_code |> get_meta_size(stream, offset)

    decode_utf8_string(size, stream, offset)
  end
  defp decode_by_type(ctrl_type, ctrl_code, stream, offset) do
    { _, offset } = ctrl_code |> get_meta_size(stream, offset)
    mod_stream    = stream |> Enum.drop(offset)

    IO.puts "unhandled type #{ctrl_type}: " <> inspect(Enum.take(mod_stream, 16))

    { nil, offset }
  end

  defp byte_to_code(byte) do
    :io_lib.format("~w", bitstring_to_list(byte))
      |> hd()
      |> list_to_integer()
  end

  defp get_meta_size(code, stream, offset) do
    case code &&& 0x1f do
      _size when 29 == _size ->
        { size, offset } = decode_uint(1, stream, offset)
        { 29 + size, offset }
      _size when 30 == _size ->
        { size, offset } = decode_uint(2, stream, offset)
        { 285 + size, offset }
      _ -> { code &&& 0x1f, offset }
    end
  end

  defp decode_array(arr, size, stream, offset) when 0 < size do
    { elem, offset } = stream |> decode(offset)

    decode_array(arr ++ [elem], size - 1, stream, offset)
  end
  defp decode_array(arr, _, _, offset) do
    { arr, offset }
  end

  defp decode_map(map, size, stream, offset) when 0 < size do
    { key, offset } = stream |> decode(offset)
    { val, offset } = stream |> decode(offset)

    decode_map(map ++ [{ key, val }], size - 1, stream, offset)
  end
  defp decode_map(map, _, _, offset) do
    { map, offset }
  end

  defp decode_uint(size, stream, offset) when 0 < size do
    bytes = stream |> Enum.drop(offset) |> Enum.take(size) |> Enum.join()
    uint  = bitstring_to_list(bytes)
      |> Enum.map(fn(x) -> integer_to_binary(x, 16) end)
      |> Enum.join()
      |> String.to_char_list!()
      |> list_to_integer(16)

    { uint, size + offset }
  end
  defp decode_uint(_, _, offset) do
    { 0, offset }
  end

  defp decode_utf8_string(size, stream, offset) do
    { stream |> Enum.drop(offset) |> Enum.take(size) |> Enum.join(), size + offset }
  end
end
