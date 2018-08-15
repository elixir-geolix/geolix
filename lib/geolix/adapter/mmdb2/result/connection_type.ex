defmodule Geolix.Adapter.MMDB2.Result.ConnectionType do
  @moduledoc """
  Result for `GeoIP2 Connection Type` databases.
  """

  alias Geolix.Adapter.MMDB2.Model

  defstruct [
    :connection_type,
    :ip_address
  ]

  @behaviour Model

  def from(data, _), do: struct(__MODULE__, data)
end
