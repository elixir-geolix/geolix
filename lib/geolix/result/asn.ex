defmodule Geolix.Result.ASN do
  @moduledoc """
  Result for `GeoLite2 ASN` databases.
  """

  @behaviour Geolix.Model

  defstruct [
    :autonomous_system_number,
    :autonomous_system_organization,
    :ip_address
  ]

  def from(data, _), do: struct(__MODULE__, data)
end
