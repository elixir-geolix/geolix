defmodule Geolix.Adapter.MMDB2.LookupTree do
  @moduledoc """
  Locates IPs in the lookup tree.
  """

  use Bitwise, only_operators: true

  require Logger

  alias Geolix.Adapter.MMDB2.Metadata


  @doc """
  Locates the data pointer associated for a given IP.
  """
  @spec locate(tuple, binary, Metadata.t) :: non_neg_integer
  def locate({ 0, 0, 0, 0, 0, 65535, a, b }, tree, meta) do
    locate({ a >>> 8, a &&& 0x00FF, b >>> 8, b &&& 0x00FF }, tree, meta)
  end

  def locate({ a, b, c, d }, tree, %{ ip_version: 6 } = meta) do
    << a :: size(8), b :: size(8), c :: size(8), d :: size(8) >>
    |> traverse(0, 32, 96, tree, meta)
  end

  def locate({ a, b, c, d }, tree, meta) do
    << a :: size(8), b :: size(8), c :: size(8), d :: size(8) >>
    |> traverse(0, 32, 0, tree, meta)
  end

  def locate({ _, _, _, _, _, _, _, _ }, _, %{ ip_version: 4 }), do: 0

  def locate({ a, b, c, d, e, f, g, h }, tree, meta) do
    << a :: size(16), b :: size(16), c :: size(16), d :: size(16),
       e :: size(16), f :: size(16), g :: size(16), h :: size(16) >>
    |> traverse(0, 128, 0, tree, meta)
  end


  defp traverse(_, bit, bit_count, node, _, %{ node_count: node_count } = meta)
  when bit < bit_count and node >= node_count
  do
    traverse(nil, nil, nil, node, nil, meta)
  end

  defp traverse(path, bit, bit_count, node, tree, %{ node_count: node_count } = meta)
  when bit < bit_count and node < node_count
  do
    rest_size = bit_count - bit - 1

    << _ :: size(bit), node_bit :: size(1), _ :: size(rest_size) >> = path

    node = read_node(node, node_bit, tree, meta)

    traverse(path, bit + 1, bit_count, node, tree, meta)
  end

  defp traverse(_, _, _, node, _, meta) do
    node_count = meta.node_count

    cond do
      node >  node_count -> node
      node == node_count -> 0
      true ->
        Logger.error "Invalid node below node_count: #{node}"
        0
    end
  end


  defp read_node(node, index, tree, meta) do
    record_size = meta.record_size
    record_half = rem(record_size, 8)
    record_left = record_size - record_half

    node_start = div(node * record_size, 4)
    node_len   = div(record_size, 4)
    node_part  = binary_part(tree, node_start, node_len)

    << low   :: size(record_left),
       high  :: size(record_half),
       right :: size(record_size) >> = node_part

    case index do
      0 -> low + (high <<< record_left)
      1 -> right
    end
  end
end
