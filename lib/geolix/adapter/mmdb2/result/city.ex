defmodule Geolix.Adapter.MMDB2.Result.City do
  @moduledoc """
  Result for `GeoIP2 City` databases.
  """

  alias Geolix.Adapter.MMDB2.Model
  alias Geolix.Adapter.MMDB2.Record

  defstruct [
    :city,
    :continent,
    :country,
    :location,
    :postal,
    :registered_country,
    :represented_country,
    :subdivisions,
    :traits
  ]

  @behaviour Model

  def from(data, locale) do
    %__MODULE__{
      city: Record.City.from(data[:city], locale),
      continent: Record.Continent.from(data[:continent], locale),
      country: Record.Country.from(data[:country], locale),
      location: Record.Location.from(data[:location], locale),
      postal: Record.Postal.from(data[:postal], locale),
      registered_country: Record.Country.from(data[:registered_country], locale),
      represented_country: Record.RepresentedCountry.from(data[:represented_country], locale),
      subdivisions: Record.Subdivision.from(data[:subdivisions], locale),
      traits: Map.get(data, :traits, %{})
    }
  end
end
