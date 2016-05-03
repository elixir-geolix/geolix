defmodule Geolix.Record.Location do
  @moduledoc """
  Record for `location` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :accuracy_radius,
    :latitude,
    :longitude,
    :metro_code,
    :time_zone
  ]

  def from(nil,  _), do: nil
  def from(data, _), do: struct(__MODULE__, data)
end
