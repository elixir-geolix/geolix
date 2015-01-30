defmodule Geolix.Result.AnonymousIP do
  @moduledoc """
  Result for `GeoIP2 Anonymous IP` databases.
  """

  @behaviour Geolix.Model

  defstruct [
    :ip_address,
    :is_anonymous,
    :is_anonymous_vpn,
    :is_hosting_provider,
    :is_public_proxy,
    :is_tor_exit_node
  ]

  def from(data) do
    %__MODULE__{
      ip_address:          data[:ip_address],
      is_anonymous:        data[:is_anonymous]        && true,
      is_anonymous_vpn:    data[:is_anonymous_vpn]    && true,
      is_hosting_provider: data[:is_hosting_provider] && true,
      is_public_proxy:     data[:is_public_proxy]     && true,
      is_tor_exit_node:    data[:is_tor_exit_node]    && true
    }
  end
end
