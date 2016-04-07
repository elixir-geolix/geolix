defmodule Geolix.Record.EnterpriseLocation do
  @moduledoc """
  Record for `location` information (enterprise database).
  """

  @behaviour Geolix.Model

  defstruct %Geolix.Record.City{}
            |> Map.keys()
            |> List.delete(:__struct__)
            |> List.flatten([ :accuracy_radius ])

  def from(nil,  _), do: nil
  def from(data, _), do: struct(__MODULE__, data)
end
