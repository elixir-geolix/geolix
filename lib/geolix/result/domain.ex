defmodule Geolix.Result.Domain do
  @moduledoc """
  Result for `GeoIP2 Domain` databases.
  """

  defstruct [
    domain: nil,
    ip_address: nil
  ]
end
