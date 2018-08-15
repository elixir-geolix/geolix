defmodule Geolix.Adapter.MMDB2.Record.EnterpriseCity do
  @moduledoc """
  Record for `city` information (enterprise database).
  """

  alias Geolix.Adapter.MMDB2.Model
  alias Geolix.Adapter.MMDB2.Record

  defstruct %Record.City{}
            |> Map.keys()
            |> List.delete(:__struct__)
            |> List.flatten([:confidence])

  @behaviour Model

  def from(nil, _), do: nil
  def from(data, nil), do: struct(__MODULE__, data)

  def from(data, locale) do
    result = from(data, nil)
    result = Map.put(result, :name, result.names[locale])

    result
  end
end
