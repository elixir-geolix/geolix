defmodule Geolix.Result.Domain do
  @moduledoc """
  Result for `GeoIP2 Domain` databases.
  """

  @behaviour Geolix.Model

  defstruct [
    :domain,
    :ip_address
  ]

  def from(data, _), do: struct(__MODULE__, data)
end
