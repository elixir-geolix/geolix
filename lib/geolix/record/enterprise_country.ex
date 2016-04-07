defmodule Geolix.Record.EnterpriseCountry do
  @moduledoc """
  Record for `country` information (enterprise database).
  """

  @behaviour Geolix.Model

  defstruct %Geolix.Record.Country{}
            |> Map.keys()
            |> List.delete(:__struct__)
            |> List.flatten([ :confidence ])

  def from(nil,       _), do: nil
  def from(data,    nil), do: struct(__MODULE__, data)
  def from(data, locale) do
    result = from(data, nil)
    result = Map.put(result, :name, result.names[locale])

    result
  end
end
