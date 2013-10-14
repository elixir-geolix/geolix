defmodule Geolix.Database do
  @metadata_marker "\xAB\xCD\xEFMaxMind.com"

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

  defp read_cities(db_dir) do
    []
  end

  defp read_countries(db_dir) do
    db_file    = db_dir <> "GeoLite2-Country.mmdb"
    db_file_gz = db_file <> ".gz"

    cond do
      File.regular?(db_file)    -> parse_countries(File.read(db_file))
      File.regular?(db_file_gz) -> parse_countries_gz(File.read(db_file_gz))
      true -> { :error, "Failed to find 'GeoLite2-Country.mmdb[.gz]' in given path '#{db_dir}'!" }
    end
  end

  defp parse_countries_gz({ :ok, gz_data }) do
    parse_countries(:zlib.gunzip(gz_data))
  end
  defp parse_countries_gz({ :error, reason }) do
    { :error, "Failed to read country db: #{reason}" }
  end

  defp parse_countries({ :ok, data }) do
    parse_countries(data)
  end
  defp parse_countries(data) when is_binary(data) do
    IO.inspect "Reading stuff! Size: " <> integer_to_binary(String.length(data))
    []
  end
end
