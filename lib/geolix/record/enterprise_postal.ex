defmodule Geolix.Record.EnterprisePostal do
  @moduledoc """
  Record for `postal` information (enterprise database).
  """

  @behaviour Geolix.Model

  defstruct %Geolix.Record.Postal{}
            |> Map.keys()
            |> List.delete(:__struct__)
            |> List.flatten([ :confidence ])

  def from(nil,  _), do: nil
  def from(data, _), do: struct(__MODULE__, data)
end
