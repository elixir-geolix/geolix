defmodule Geolix.Adapter.MMDB2.Result.ASN do
  @moduledoc """
  Result for `GeoLite2 ASN` databases.
  """

  alias Geolix.Adapter.MMDB2.Model

  defstruct [
    :autonomous_system_number,
    :autonomous_system_organization,
    :ip_address
  ]

  @behaviour Model

  def from(data, _), do: struct(__MODULE__, data)
end
