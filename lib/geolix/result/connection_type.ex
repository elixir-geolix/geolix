defmodule Geolix.Result.ConnectionType do
  @moduledoc """
  Result for `GeoIP2 Connection Type` databases.
  """

  @behaviour Geolix.Model

  defstruct [
    :connection_type,
    :ip_address
  ]

  def from(data), do: struct(__MODULE__, data)
end
