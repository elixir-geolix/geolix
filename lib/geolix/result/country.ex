defmodule Geolix.Result.Country do
  @moduledoc """
  Result for `GeoIP2 Country` databases.
  """

  alias Geolix.Record

  @behaviour Geolix.Model

  defstruct [
    :continent,
    :country,
    :registered_country,
    :represented_country,
    :traits
  ]

  def from(data) do
    %__MODULE__{
      continent:           Record.Continent.from(data[:continent]),
      country:             Record.Country.from(data[:country]),
      registered_country:  Record.Country.from(data[:registered_country]),
      represented_country: Record.RepresentedCountry.from(data[:represented_country]),
      traits:              %{}
    }
  end
end
