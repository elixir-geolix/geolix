defmodule Geolix.Adapter.MMDB2.Record.EnterpriseSubdivision do
  @moduledoc """
  Record for `subdivision` information (enterprise database).
  """

  alias Geolix.Adapter.MMDB2.Model
  alias Geolix.Adapter.MMDB2.Record

  defstruct %Record.Subdivision{}
            |> Map.keys()
            |> List.delete(:__struct__)
            |> List.flatten([:confidence])

  @behaviour Model

  def from(nil, _), do: nil

  def from(data, locale) when is_list(data) do
    data |> Enum.map(&from(&1, locale))
  end

  def from(data, nil), do: struct(__MODULE__, data)

  def from(data, locale) do
    result = from(data, nil)
    result = Map.put(result, :name, result.names[locale])

    result
  end
end
