defmodule Geolix.Reader do
  @moduledoc """
  Module to read database files and split them into data and metadata.
  """

  @metadata_marker <<171, 205, 239>> <> "MaxMind.com"

  @doc """
  Reads a database file and returns the data and metadata parts from it.
  """
  @spec read_database(String.t) :: { binary, binary }
  def read_database(filename) do
    { :ok, %{ size: filesize }} = File.stat(filename)

    stream   = File.stream!(filename, [ :read ], 1)
    data     = ""
    max_meta = 128 * 1024

    if filesize > max_meta do
      meta_drop = filesize - max_meta
      data      = stream |> Enum.take(meta_drop) |> Enum.join()
      stream    = stream |> Enum.drop(meta_drop)
    end

    split_data(data, stream)
  end

  # <<171>> == first char of @metadata_marker
  # 14      == byte_size of @metadata_marker
  defp split_data(data, stream) do
    size_old  = byte_size(data)
    data      = data <> (stream |> Enum.take_while( &(&1 != <<171>>) ) |> Enum.join())
    size_read = byte_size(data) - size_old

    if 0 < size_read do
      stream = stream |> Enum.drop(size_read)
    end

    maybe_marker = stream |> Enum.take(14) |> Enum.join()
    stream       = stream |> Enum.drop(14)

    if maybe_marker == @metadata_marker do
      { data, Enum.join(stream) }
    else
      split_data(data <> maybe_marker, stream)
    end
  end
end
