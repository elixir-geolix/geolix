defmodule Geolix.Result.ISP do
  @moduledoc """
  Result for `GeoIP2 ISP` databases.
  """

  @behaviour Geolix.Model

  defstruct [
    :autonomous_system_number,
    :autonomous_system_organization,
    :ip_address,
    :isp,
    :organization
  ]

  def from(data), do: struct(__MODULE__, data)
end
