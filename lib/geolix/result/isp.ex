defmodule Geolix.Result.ISP do
  @moduledoc """
  Result for `GeoIP2 ISP` databases.
  """

  defstruct [
    autonomous_system_number: nil,
    autonomous_system_organization: nil,
    ip_address: nil,
    isp: nil,
    organization: nil
  ]
end
