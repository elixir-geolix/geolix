defmodule Geolix.TestFixtures.Download do
  @moduledoc false

  @doc """
  Downloads all fixture files.
  """
  def run() do
    Enum.each(Geolix.TestFixtures.List.get(), &download/1)
  end

  defp download({ _name, filename, remote }) do
    local = local(filename)

    if not File.regular?(local) do
      Mix.shell.info [ :yellow, "Downloading fixture database: #{ filename }" ]

      download_fixture(remote, local)
    end
  end

  defp download_fixture(remote, local) do
    content = case Version.match?(System.version, ">= 1.1.0") do
      false -> Mix.Utils.read_path!(remote)
      true  ->
        { :ok, data } = Mix.Utils.read_path(remote)
        data
    end

    File.write! local, content
  end

  defp local(filename) do
    [ __DIR__, filename ]
    |> Path.join()
    |> Path.expand()
  end
end
