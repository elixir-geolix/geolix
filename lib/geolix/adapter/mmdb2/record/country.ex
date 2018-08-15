defmodule Geolix.Adapter.MMDB2.Record.Country do
  @moduledoc """
  Record for `country` information.
  """

  alias Geolix.Adapter.MMDB2.Model

  defstruct [
    :geoname_id,
    :is_in_european_union,
    :iso_code,
    :name,
    :names
  ]

  @behaviour Model

  def from(nil, _), do: nil

  def from(data, nil) do
    struct(__MODULE__, Map.put_new(data, :is_in_european_union, false))
  end

  def from(data, locale) do
    result = from(data, nil)
    result = Map.put(result, :name, result.names[locale])

    result
  end
end
