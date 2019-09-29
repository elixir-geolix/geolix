defmodule Geolix.Database.Fetcher do
  @moduledoc false

  @doc """
  Returns all configured databases.

  Initializer functions will be applied if configured.
  """
  @spec databases :: [map]
  def databases do
    :geolix
    |> Application.get_env(:databases, [])
    |> Enum.map(&preconfigure_database/1)
  end

  defp preconfigure_database(%{init: {mod, fun, extra_args}} = config) do
    apply(mod, fun, [config | extra_args])
  end

  defp preconfigure_database(%{init: {mod, fun}} = config) do
    apply(mod, fun, [config])
  end

  defp preconfigure_database(config), do: config
end
