defmodule Geolix.Result.Country do
  @moduledoc """
  Result for `GeoIP2 Country` databases.
  """

  defstruct [
    continent: %{},
    country: %{},
    registered_country: %{},
    represented_country: %{},
    traits: %{ ip_address: nil }
  ]
end
