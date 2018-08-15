defmodule Geolix.Adapter.MMDB2.Record.Location do
  @moduledoc """
  Record for `location` information.
  """

  alias Geolix.Adapter.MMDB2.Model

  defstruct [
    :accuracy_radius,
    :latitude,
    :longitude,
    :metro_code,
    :time_zone
  ]

  @behaviour Model

  def from(nil, _), do: nil
  def from(data, _), do: struct(__MODULE__, data)
end
