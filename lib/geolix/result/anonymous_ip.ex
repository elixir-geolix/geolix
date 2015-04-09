defmodule Geolix.Result.AnonymousIP do
  @moduledoc """
  Result for `GeoIP2 Anonymous IP` databases.
  """

  @behaviour Geolix.Model

  defstruct [
    ip_address:          nil,
    is_anonymous:        false,
    is_anonymous_vpn:    false,
    is_hosting_provider: false,
    is_public_proxy:     false,
    is_tor_exit_node:    false
  ]

  def from(data, _), do: struct(__MODULE__, data)
end
