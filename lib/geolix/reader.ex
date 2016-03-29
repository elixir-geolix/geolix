defmodule Geolix.Reader do
  @moduledoc """
  Module to read database files and split them into data and metadata.
  """

  @metadata_marker << 0xAB, 0xCD, 0xEF >> <> "MaxMind.com"

  @doc """
  Reads a database file and returns the data and metadata parts from it.
  """
  @spec read_database(String.t) :: { binary | :error, binary | :no_metadata }
  def read_database(filename) do
    filename
    |> File.read!
    |> maybe_gunzip(filename)
    |> :binary.split(@metadata_marker)
    |> maybe_succeed()
  end

  @doc """
  Handles remote binary data and returns the data and metadata parts from it.
  """
  @spec handle_binary(Binary.t, String.t) :: { binary | :error, binary | :no_metadata }
  def handle_binary(binary, filename) do
    binary
    |> maybe_gunzip(filename)
    |> :binary.split(@metadata_marker)
    |> maybe_succeed()
  end

  defp maybe_gunzip(data, filename) do
    case String.ends_with?(filename, ".gz") do
      true  -> :zlib.gunzip(data)
      false -> data
    end
  end

  defp maybe_succeed([ _data ]),      do: { :error, :no_metadata }
  defp maybe_succeed([ data, meta ]), do: { data, meta }
end
