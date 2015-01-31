defmodule Geolix.Record.RepresentedCountry do
  @moduledoc """
  Record for `represented country` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :geoname_id,
    :iso_code,
    :names,
    :type
  ]

  def from(nil),  do: nil
  def from(data), do: struct(__MODULE__, data)
end
