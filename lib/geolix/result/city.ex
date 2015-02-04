defmodule Geolix.Result.City do
  @moduledoc """
  Result for `GeoIP2 City` databases.
  """

  alias Geolix.Record

  @behaviour Geolix.Model

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

  def from(data) do
    %__MODULE__{
      city:                Record.City.from(data[:city]),
      continent:           Record.Continent.from(data[:continent]),
      country:             Record.Country.from(data[:country]),
      location:            Record.Location.from(data[:location]),
      postal:              Record.Postal.from(data[:postal]),
      registered_country:  Record.Country.from(data[:registered_country]),
      represented_country: Record.RepresentedCountry.from(data[:represented_country]),
      subdivisions:        Record.Subdivision.from(data[:subdivisions]),
      traits:              %{}
    }
  end
end
