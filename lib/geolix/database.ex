defmodule Geolix.Database do
  @metadata_marker <<171, 205, 239>> <> "MaxMind.com"

  @doc """
  Returns city data from file found in directory.
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
  Returns country data from file found in directory.
  """
  def read_countries(db_dir) do
    db_file    = db_dir <> "GeoLite2-Country.mmdb"
    db_file_gz = db_file <> ".gz"

    cond do
      File.regular?(db_file)    -> parse_file({ :regular, db_file })
      File.regular?(db_file_gz) -> parse_file({ :gzip , db_file_gz})
      true -> { :error, "Failed to find 'GeoLite2-Country.mmdb[.gz]' in given path '#{db_dir}' !" }
    end
  end

  defp parse_file({ :regular, db_file }) do
    File.binstream!(db_file, [:read], 1) |> parse_stream()
  end
  defp parse_file({ :gzip, db_file }) do
    File.binstream!(db_file, [:read, :compressed], 1) |> parse_stream()
  end

  defp parse_stream(stream) do
    { metadata, _ } = drop_until_meta(stream) |> Geolix.Decoder.decode()
    metadata        = HashDict.new(metadata)
    metadata        = HashDict.put(metadata, "node_byte_size", div(HashDict.get(metadata, "record_size", 0), 4))
    metadata        = HashDict.put(
      metadata, "search_tree_size",
      HashDict.get(metadata, "node_count", 0) * HashDict.get(metadata, "node_byte_size", 0))

    { metadata, {} }
  end

  defp drop_until_meta(stream) do
    stream = Enum.drop_while(stream, fn(c) -> c != String.at(@metadata_marker, 0) end)
    marker = Enum.take(stream, byte_size(@metadata_marker)) |> Enum.join()

    if marker == @metadata_marker do
      Enum.drop(stream, byte_size(@metadata_marker))
    else
      Enum.drop(stream, 1) |> drop_until_meta()
    end
  end
end
