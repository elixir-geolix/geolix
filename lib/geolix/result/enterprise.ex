defmodule Geolix.Result.Enterprise do
  @moduledoc """
  Result for `GeoIP2 Enterprise` databases.
  """

  alias Geolix.Record

  @behaviour Geolix.Model

  defstruct %Geolix.Result.City{}
            |> Map.keys()
            |> List.delete(:__struct__)

  def from(data, locale) do
    %__MODULE__{
      city: Record.EnterpriseCity.from(data[:city], locale),
      continent: Record.Continent.from(data[:continent], locale),
      country: Record.EnterpriseCountry.from(data[:country], locale),
      location: Record.Location.from(data[:location], locale),
      postal: Record.EnterprisePostal.from(data[:postal], locale),
      registered_country: Record.Country.from(data[:registered_country], locale),
      represented_country: Record.RepresentedCountry.from(data[:represented_country], locale),
      subdivisions: Record.EnterpriseSubdivision.from(data[:subdivisions], locale),
      traits: Map.get(data, :traits, %{})
    }
  end
end
