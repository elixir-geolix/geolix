defmodule Geolix.Record.Location do
  @moduledoc """
  Record for `location` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :latitude,
    :longitude,
    :metro_code,
    :time_zone
  ]

  def from(nil),  do: nil
  def from(data), do: struct(__MODULE__, data)
end
