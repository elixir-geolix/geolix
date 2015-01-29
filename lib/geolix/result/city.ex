defmodule Geolix.Result.City do
  @moduledoc """
  Result for `GeoIP2 City` databases.
  """

  defstruct [
    city: %{},
    continent: %{},
    country: %{},
    location: %{},
    postal: %{},
    registered_country: %{},
    represented_country: %{},
    subdivisions: [],
    traits: %{ ip_address: nil }
  ]
end
