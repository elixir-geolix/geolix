defmodule Geolix.Database do
  @metadata_marker <<171, 205, 239>> <> "MaxMind.com"

  def read(db_dir) do
    cities    = read_cities(db_dir)
    countries = read_countries(db_dir)

    cond do
      is_list(cities) and is_list(countries) -> cities ++ countries
      is_tuple(cities)    -> cities
      is_tuple(countries) -> countries
      true -> { :error, "Unknown error" }
    end
  end

  defp read_cities(_) do
    []
  end

  defp read_countries(db_dir) do
    db_file    = db_dir <> "GeoLite2-Country.mmdb"
    db_file_gz = db_file <> ".gz"

    cond do
      File.regular?(db_file)    -> parse_countries({ :regular, db_file })
      File.regular?(db_file_gz) -> parse_countries({ :gzip , db_file_gz})
      true -> { :error, "Failed to find 'GeoLite2-Country.mmdb[.gz]' in given path '#{db_dir}'!" }
    end
  end

  defp parse_countries({ :regular, db_file }) do
    stream_countries(File.binstream!(db_file, [:read], 1))
  end
  defp parse_countries({ :gzip, db_file }) do
    stream_countries(File.binstream!(db_file, [:read, :compressed], 1))
  end

  defp stream_countries(stream) do
    meta_stream = drop_until_meta(stream)

    IO.puts inspect(@metadata_marker) <> " <> " <> inspect(Enum.join(Enum.take(meta_stream, byte_size(@metadata_marker))))
  end

  defp drop_until_meta(stream) do
    stream = Enum.drop_while(stream, fn(c) -> c != String.at(@metadata_marker, 0) end)
    marker = Enum.take(stream, byte_size(@metadata_marker)) |> Enum.join

    if marker == @metadata_marker do
      stream
    else
      drop_until_meta(Enum.drop(stream, 1))
    end
  end
end
