defmodule Geolix.Record.RepresentedCountry do
  @moduledoc """
  Record for `represented country` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :geoname_id,
    :iso_code,
    :name,
    :names,
    :type
  ]

  def from(nil, _), do: nil
  def from(data, nil), do: struct(__MODULE__, data)

  def from(data, locale) do
    result = from(data, nil)
    result = Map.put(result, :name, result.names[locale])

    result
  end
end
