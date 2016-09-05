defmodule Geolix.Adapter.MMDB2.Decoder do
  @moduledoc """
  Module for decoding the mmdb2 format byte streams.
  """

  @type decoded :: atom | binary | boolean | list | map


  @array         4 # extended: 11
  @bool          7 # extended: 14
  @binary        2
  @bytes         4
  @cache         5 # extended: 12
  @double        3
  @end_marker    6 # extended: 13
  @extended      0
  @float         8 # extended: 15
  @map           7
  @signed_32     1 # extended:  8
  @unsigned_16   5
  @unsigned_32   6
  @unsigned_64   2 # extended:  9
  @unsigned_128  3 # extended: 10
  @pointer       1


  @doc """
  Decodes the datatype found at the given offset of the data.
  """
  @spec decode(binary, binary) :: { decoded, binary }
  def decode(_, << @binary :: size(3), len :: size(5), data_part :: binary >>) do
    decode_binary(len, data_part)
  end

  def decode(_, << @bytes :: size(3), len :: size(5), data_part :: binary >>) do
    decode_binary(len, data_part)
  end

  def decode(_, << @double :: size(3), 8 :: size(5), value :: size(64)-float, data_part :: binary >>) do
    { Float.round(value, 8), data_part }
  end

  def decode(data, << @extended :: size(3), len :: size(5), @array, data_part :: binary >>) do
    decode_array(len, data, data_part)
  end

  def decode(_, << @extended :: size(3), value :: size(5), @bool, data_part :: binary >>) do
    { 1 == value, data_part }
  end

  def decode(_, << @extended :: size(3), _ :: size(5), @cache, data_part :: binary >>) do
    { :cache, data_part }
  end

  def decode(_, << @extended :: size(3), 0 :: size(5), @end_marker, data_part :: binary >>) do
    { :end, data_part }
  end

  def decode(_, << @extended :: size(3), 4 :: size(5), @float, value :: size(32)-float, data_part :: binary >>) do
    { Float.round(value, 4), data_part }
  end

  def decode(_, << @extended :: size(3), len :: size(5), @signed_32, data_part :: binary >>) do
    decode_signed(len, data_part)
  end

  def decode(_, << @extended :: size(3), len :: size(5), @unsigned_64, data_part :: binary >>) do
    decode_unsigned(len, data_part)
  end

  def decode(_, << @extended :: size(3), len :: size(5), @unsigned_128, data_part :: binary >>) do
    decode_unsigned(len, data_part)
  end

  def decode(data, << @map :: size(3), len :: size(5), data_part :: binary>>) do
    decode_map(len, data, data_part)
  end

  def decode(data, << @pointer :: size(3), len :: size(2), data_part :: bitstring >>) do
    decode_pointer(len, data, data_part)
  end

  def decode(_, << @unsigned_16 :: size(3), len :: size(5), data_part :: binary >>) do
    decode_unsigned(len, data_part)
  end

  def decode(_, << @unsigned_32 :: size(3), len :: size(5), data_part :: binary >>) do
    decode_unsigned(len, data_part)
  end

  @doc """
  Decodes the node at the given offset.
  """
  @spec value(binary, non_neg_integer) :: decoded
  def value(data, offset) when byte_size(data) > offset do
    << _ :: size(offset)-binary, rest :: binary >> = data

    { value, _rest } = decode(data, rest)

    value
  end

  def value(_, _), do: nil


  # value decoding

  defp decode_array(len, data, data_part) do
    { size, data_part } = payload_len(len, data_part)

    decode_array_rec(size, data, data_part, [])
  end

  defp decode_array_rec(0, _, data_part, acc) do
    { Enum.reverse(acc), data_part }
  end

  defp decode_array_rec(size, data, data_part, acc) do
    { value, rest } = decode(data, data_part)

    decode_array_rec(size - 1, data, rest, [ value | acc ])
  end

  defp decode_binary(len, data_part) do
    { len, data_part } = payload_len(len, data_part)

    << value :: size(len)-binary, rest :: binary >> = data_part

    { value, rest }
  end

  defp decode_map(len, data, data_part) do
    { size, data_part} = payload_len(len, data_part)

    decode_map_rec(size, data, data_part, %{})
  end

  defp decode_map_rec(0, _, data_part, acc) do
    { acc, data_part }
  end

  defp decode_map_rec(size, data, data_part, acc) do
    { key,   rest } = decode(data, data_part)
    { value, rest } = decode(data, rest)

    acc = Map.put(acc, String.to_atom(key), value)

    decode_map_rec(size - 1, data, rest, acc)
  end

  defp decode_pointer(0, data, data_part) do
    << offset :: size(11), rest :: binary >> = data_part

    { value(data, offset), rest }
  end

  defp decode_pointer(1, data, data_part) do
    << offset :: size(19), rest :: binary >> = data_part

    { value(data, offset + 2048), rest }
  end

  defp decode_pointer(2, data, data_part) do
    << offset :: size(27), rest :: binary >> = data_part

    { value(data, offset + 526336), rest }
  end

  defp decode_pointer(3, data, data_part) do
    << _ :: size(3), offset :: size(32), rest :: binary >> = data_part

    { value(data, offset), rest }
  end

  defp decode_signed(len, data_part) do
    bitlen = len * 8

    << value :: size(bitlen)-integer-signed, rest :: binary >> = data_part

    { value, rest }
  end

  defp decode_unsigned(len, data_part) do
    bitlen = len * 8

    << value :: size(bitlen)-integer-unsigned, rest :: binary >> = data_part

    { value, rest }
  end


  # payload detection

  defp payload_len(29, << len :: size(8), data :: binary >>) do
    { 29 + len, data }
  end

  defp payload_len(30, << len :: size(16), data :: binary >>) do
    { 285 + len, data }
  end

  defp payload_len(31, << len :: size(24), data :: binary >>) do
    { 65821 + len, data }
  end

  defp payload_len(len, data), do: { len, data }
end
