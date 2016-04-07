defmodule Geolix.Record.EnterpriseSubdivision do
  @moduledoc """
  Record for `subdivision` information (enterprise database).
  """

  @behaviour Geolix.Model

  defstruct %Geolix.Record.Subdivision{}
            |> Map.keys()
            |> List.delete(:__struct__)
            |> List.flatten([ :confidence ])

  def from(nil, _), do: nil

  def from(data, locale) when is_list(data) do
    data |> Enum.map( &from(&1, locale) )
  end

  def from(data,    nil), do: struct(__MODULE__, data)
  def from(data, locale) do
    result = from(data, nil)
    result = Map.put(result, :name, result.names[locale])

    result
  end
end
