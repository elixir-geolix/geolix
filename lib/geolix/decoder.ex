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
  Decodes the datatype found at the start of the datastring.
  """
  def decode(data) do
    decode(data, 0)
  end

  @doc """
  Decodes the datatype found at the given offset of the data.
  """
  def decode(data, offset) do
    ctrl_code = data |> binary_part(offset, 1) |> byte_to_code()
    ctrl_type = Enum.at(@ctrl_types, ctrl_code >>> 5)

    decode_by_type(ctrl_type, ctrl_code, data, 1 + offset)
  end

  defp decode_by_type(:array, ctrl_code, data, offset) do
    { size, offset } = ctrl_code |> get_meta_size(data, offset)

    decode_array([], size, data, offset)
  end
  defp decode_by_type(:extended, ctrl_code, data, offset) do
    ext_code  = data |> binary_part(offset, 1) |> byte_to_code()
    ctrl_type = Enum.at(@ctrl_types, ext_code + 7)

    decode_by_type(ctrl_type, ctrl_code, data, 1 + offset)
  end
  defp decode_by_type(:map, ctrl_code, data, offset) do
    { size, offset } = ctrl_code |> get_meta_size(data, offset)

    decode_map([], size, data, offset)
  end
  defp decode_by_type(:pointer, ctrl_code, data, offset) do
    size   = ((ctrl_code >>> 3) &&& 0x3) + 1
    buffer = data |> binary_part(offset, size)

    if 4 > size do
      buffer = <<ctrl_code &&& 0x7>> <> buffer
    end

    ptr = buffer
      |> bitstring_to_list()
      |> Enum.map(fn(x) -> integer_to_binary(x, 16) end)
      |> Enum.join()
      |> String.to_char_list!()
      |> list_to_integer(16)

    case size do
      2 -> ptr = ptr + 2048
      3 -> ptr = ptr + 526336
      _ -> nil
    end

    { ptr_data, _ } = decode(data, ptr)
    { ptr_data, offset + size }
  end
  defp decode_by_type(:uint16, ctrl_code, data, offset) do
    decode_by_type(:uint64, ctrl_code, data, offset)
  end
  defp decode_by_type(:uint32, ctrl_code, data, offset) do
    decode_by_type(:uint64, ctrl_code, data, offset)
  end
  defp decode_by_type(:uint64, ctrl_code, data, offset) do
    { size, offset } = ctrl_code |> get_meta_size(data, offset)

    decode_uint(size, data, offset)
  end
  defp decode_by_type(:utf8_string, ctrl_code, data, offset) do
    { size, offset } = ctrl_code |> get_meta_size(data, offset)

    decode_utf8_string(size, data, offset)
  end
  defp decode_by_type(ctrl_type, ctrl_code, data, offset) do
    { _, offset } = ctrl_code |> get_meta_size(data, offset)

    IO.puts "unhandled type #{ctrl_type}: " <> inspect(binary_part(data, offset, 16))

    { nil, offset }
  end

  defp byte_to_code(byte) do
    :io_lib.format("~w", bitstring_to_list(byte))
      |> hd()
      |> list_to_integer()
  end

  defp get_meta_size(code, data, offset) do
    case code &&& 0x1f do
      _size when 29 == _size ->
        { size, offset } = decode_uint(1, data, offset)
        { 29 + size, offset }
      _size when 30 == _size ->
        { size, offset } = decode_uint(2, data, offset)
        { 285 + size, offset }
      _ -> { code &&& 0x1f, offset }
    end
  end

  defp decode_array(arr, size, data, offset) when 0 < size do
    { elem, offset } = data |> decode(offset)

    decode_array(arr ++ [elem], size - 1, data, offset)
  end
  defp decode_array(arr, _, _, offset) do
    { arr, offset }
  end

  defp decode_map(map, size, data, offset) when 0 < size do
    { key, offset } = data |> decode(offset)
    { val, offset } = data |> decode(offset)

    decode_map(map ++ [{ key, val }], size - 1, data, offset)
  end
  defp decode_map(map, _, _, offset) do
    { map, offset }
  end

  defp decode_uint(size, data, offset) when 0 < size do
    uint = data
      |> binary_part(offset, size)
      |> :binary.bin_to_list()
      |> Enum.map(fn(x) -> integer_to_binary(x, 16) end)
      |> Enum.join()
      |> String.to_char_list!()
      |> list_to_integer(16)

    { uint, size + offset }
  end
  defp decode_uint(_, _, offset) do
    { 0, offset }
  end

  defp decode_utf8_string(size, data, offset) do
    { data |> binary_part(offset, size), size + offset }
  end
end