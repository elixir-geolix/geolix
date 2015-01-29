defmodule Geolix.Result.ConnectionType do
  @moduledoc """
  Result for `GeoIP2 Connection Type` databases.
  """

  defstruct [
    connection_type: nil,
    ip_address: nil
  ]
end
