defmodule Geolix.Adapter.MMDB2.Result.Domain do
  @moduledoc """
  Result for `GeoIP2 Domain` databases.
  """

  alias Geolix.Adapter.MMDB2.Model

  defstruct [
    :domain,
    :ip_address
  ]

  @behaviour Model

  def from(data, _), do: struct(__MODULE__, data)
end
