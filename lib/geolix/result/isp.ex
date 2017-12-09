defmodule Geolix.Result.ISP do
  @moduledoc """
  Result for `GeoIP2 ISP` databases.
  """

  @behaviour Geolix.Model

  defstruct %Geolix.Result.ASN{}
            |> Map.keys()
            |> List.delete(:__struct__)
            |> List.flatten([:isp, :organization])

  def from(data, _), do: struct(__MODULE__, data)
end
