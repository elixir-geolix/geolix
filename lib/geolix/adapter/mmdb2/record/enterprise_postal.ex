defmodule Geolix.Adapter.MMDB2.Record.EnterprisePostal do
  @moduledoc """
  Record for `postal` information (enterprise database).
  """

  alias Geolix.Adapter.MMDB2.Model
  alias Geolix.Adapter.MMDB2.Record

  defstruct %Record.Postal{}
            |> Map.keys()
            |> List.delete(:__struct__)
            |> List.flatten([:confidence])

  @behaviour Model

  def from(nil, _), do: nil
  def from(data, _), do: struct(__MODULE__, data)
end
