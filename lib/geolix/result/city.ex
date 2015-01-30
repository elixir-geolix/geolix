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
      country:             data[:country],
      location:            data[:location],
      postal:              data[:postal],
      registered_country:  data[:registered_country],
      represented_country: data[:represented_country],
      subdivisions:        data[:subdivisions],
      traits:              %{}
    }
  end
end
