defmodule Geolix.TestHelpers.FixtureDownload do
  @moduledoc false

  alias Geolix.TestHelpers.FixtureList

  @doc """
  Downloads all fixture files.
  """
  def run() do
    Enum.each(FixtureList.get(), &download/1)
  end

  defp download({_name, filename, remote}) do
    local = local(filename)

    if not File.regular?(local) do
      Mix.shell().info([:yellow, "Downloading fixture database: #{filename}"])

      download_fixture(remote, local)
    end
  end

  defp download_fixture(remote, local) do
    {:ok, _} = Application.ensure_all_started(:hackney)
    {:ok, _, _, client} = :hackney.get(remote)
    {:ok, content} = :hackney.body(client)

    File.write!(local, content)
  end

  defp local(filename) do
    [__DIR__, "../fixtures/", filename]
    |> Path.join()
    |> Path.expand()
  end
end
