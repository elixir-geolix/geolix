defmodule Geolix.Adapter.MMDB2.Database do
  @moduledoc """
  Module to interact with mmdb2 databases.

  This includes proxy methods for reading the database and lookup up
  entries.
  """

  alias Geolix.Adapter.MMDB2.Storage


  @doc """
  Implementation of `Geolix.Adapter.MMDB2.lookup/2`.
  """
  @spec lookup(tuple, Keyword.t) :: map | nil
  def lookup(ip, opts) do
    case opts[:where] do
      nil   -> nil
      where -> lookup(ip, where, opts)
    end
  end


  defp lookup(ip, where, opts) do
    data = Storage.Data.get(where)
    meta = Storage.Metadata.get(where)
    tree = Storage.Tree.get(where)

    lookup(ip, data, meta, tree, opts)
  end

  defp lookup(ip, data, meta, tree, opts) do
    ip
    |> MMDB2Decoder.lookup(meta, tree, data)
    |> maybe_include_ip(ip)
    |> maybe_to_struct(meta.database_type, opts[:as] || :struct, opts)
  end

  defp maybe_include_ip(nil,     _), do: nil
  defp maybe_include_ip(result, ip), do: Map.put(result, :ip_address, ip)

  defp maybe_to_struct(result,    _, :raw,       _),  do: result
  defp maybe_to_struct(result, type, :struct, opts) do
    Geolix.Result.to_struct(type, result, opts[:locale])
  end
end
