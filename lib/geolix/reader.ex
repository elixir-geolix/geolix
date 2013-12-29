defmodule Geolix.Reader do
  @metadata_marker <<171, 205, 239>> <> "MaxMind.com"

  @doc """
  Returns data from city database file.
  """
  def read_cities(db_dir) do
    db_file    = db_dir <> "GeoLite2-City.mmdb"
    db_file_gz = db_file <> ".gz"

    cond do
      File.regular?(db_file)    -> parse_file({ :regular, db_file })
      File.regular?(db_file_gz) -> parse_file({ :gzip , db_file_gz})
      true -> { :error, "Failed to find 'GeoLite2-City.mmdb[.gz]' in given path '#{db_dir}' !" }
    end
  end

  @doc """
  Returns data from country database file.
  """
  def read_countries(db_dir) do
    db_file    = db_dir  <> "GeoLite2-Country.mmdb"
    db_file_gz = db_file <> ".gz"

    cond do
      File.regular?(db_file)    -> parse_file({ :regular, db_file })
      File.regular?(db_file_gz) -> parse_file({ :gzip , db_file_gz})
      true -> { :error, "Failed to find 'GeoLite2-Country.mmdb[.gz]' in given path '#{db_dir}' !" }
    end
  end

  defp parse_file({ :regular, db_file }) do
    db_file |> File.stream!([:read], 1) |> split_stream()
  end
  defp parse_file({ :gzip, db_file }) do
    db_file |> File.stream!([:read, :compressed], 1) |> split_stream()
  end

  defp split_stream(stream) do
    { data, meta } = split_data(nil, stream)

    { :ok, data, Enum.join(meta) }
  end

  # <<171>> == first char of @metadata_marker
  # 14      == byte_size of @metadata_marker
  defp split_data(nil, stream) do
    split_data(( stream |> Enum.take(1) |> Enum.join() ), ( stream |> Enum.drop(1) ))
  end
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
      { data, stream }
    else
      split_data(data <> maybe_marker, stream)
    end
  end
end
