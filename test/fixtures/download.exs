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
      File.write! local, Mix.Utils.read_path!(remote)
    end
  end

  defp local(filename) do
    [ __DIR__, filename ]
    |> Path.join()
    |> Path.expand()
  end
end
