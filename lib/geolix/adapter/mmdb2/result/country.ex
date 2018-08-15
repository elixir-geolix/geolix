defmodule Geolix.Adapter.MMDB2.Result.Country do
  @moduledoc """
  Result for `GeoIP2 Country` databases.
  """

  alias Geolix.Adapter.MMDB2.Model
  alias Geolix.Adapter.MMDB2.Record

  defstruct [
    :continent,
    :country,
    :registered_country,
    :represented_country,
    :traits
  ]

  @behaviour Model

  def from(data, locale) do
    %__MODULE__{
      continent: Record.Continent.from(data[:continent], locale),
      country: Record.Country.from(data[:country], locale),
      registered_country: Record.Country.from(data[:registered_country], locale),
      represented_country: Record.RepresentedCountry.from(data[:represented_country], locale),
      traits: Map.get(data, :traits, %{})
    }
  end
end
