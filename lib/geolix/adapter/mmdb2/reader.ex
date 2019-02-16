defmodule Geolix.Adapter.MMDB2.Reader do
  @moduledoc """
  Module to read mmdb2 database files and split them into data and metadata.
  """

  alias MMDB2Decoder.Metadata

  @doc """
  Reads a database file and returns the data and metadata parts from it.
  """
  @spec read_database(String.t()) ::
          {:ok, Metadata.t(), binary, binary}
          | {:error, term}
  def read_database("http" <> _ = filename) do
    {:ok, _} = Application.ensure_all_started(:inets)

    case :httpc.request(String.to_charlist(filename)) do
      {:ok, {{_, 200, _}, _, body}} ->
        body
        |> IO.iodata_to_binary()
        |> maybe_gunzip(filename)
        |> maybe_untar(filename)
        |> MMDB2Decoder.parse_database()

      {:error, err} ->
        {:error, {:remote, err}}
    end
  end

  def read_database(nil), do: {:error, :enoent}

  def read_database(filename) do
    case File.regular?(filename) do
      true ->
        filename
        |> File.read!()
        |> maybe_gunzip(filename)
        |> maybe_untar(filename)
        |> MMDB2Decoder.parse_database()

      false ->
        {:error, :enoent}
    end
  end

  defp find_mmdb_contents([]), do: nil

  defp find_mmdb_contents([{file, contents} | files]) do
    case String.ends_with?(to_string(file), ".mmdb") do
      false -> find_mmdb_contents(files)
      true -> contents
    end
  end

  defp maybe_untar(data, filename) do
    case String.ends_with?(filename, [".tar", ".tar.gz"]) do
      false ->
        data

      true ->
        {:ok, files} = :erl_tar.extract({:binary, data}, [:memory])

        find_mmdb_contents(files)
    end
  end

  defp maybe_gunzip(data, filename) do
    case String.ends_with?(filename, ".gz") do
      false -> data
      true -> :zlib.gunzip(data)
    end
  end
end
