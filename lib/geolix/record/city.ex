defmodule Geolix.Record.City do
  @moduledoc """
  Record for `city` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :geoname_id,
    :name,
    :names
  ]

  def from(nil,       _), do: nil
  def from(data,    nil), do: struct(__MODULE__, data)
  def from(data, locale) do
    result = from(data, nil)
    result = Map.put(result, :name, result.names[locale])

    result
  end
end
