defmodule Geolix.Adapter.MMDB2.Result.ISP do
  @moduledoc """
  Result for `GeoIP2 ISP` databases.
  """

  alias Geolix.Adapter.MMDB2.Model
  alias Geolix.Adapter.MMDB2.Result

  defstruct %Result.ASN{}
            |> Map.keys()
            |> List.delete(:__struct__)
            |> List.flatten([:isp, :organization])

  @behaviour Model
  def from(data, _), do: struct(__MODULE__, data)
end
