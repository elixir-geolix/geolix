defmodule Geolix.Adapter.MMDB2.Reader do
  @moduledoc """
  Module to read mmdb2 database files and split them into data and metadata.
  """

  @metadata_marker << 0xAB, 0xCD, 0xEF >> <> "MaxMind.com"

  @doc """
  Reads a database file and returns the data and metadata parts from it.
  """
  @spec read_database(String.t) :: { binary | :error,
                                     binary | term }
  def read_database("http" <> _ = filename) do
    { :ok, _ } = Application.ensure_all_started(:inets)

    case :httpc.request(filename |> to_char_list) do
      { :ok, {{ _, 200, _ }, _, body }} ->
        body
        |> IO.iodata_to_binary()
        |> maybe_gunzip(filename)
        |> :binary.split(@metadata_marker)
        |> maybe_succeed()

      { :error, err } -> { :error, { :remote, err }}
    end
  end

  def read_database(filename) do
    case File.regular?(filename) do
      true ->
        filename
        |> File.read!
        |> maybe_gunzip(filename)
        |> :binary.split(@metadata_marker)
        |> maybe_succeed()

      false -> { :error, :enoent }
    end
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
