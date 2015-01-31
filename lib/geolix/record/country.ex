defmodule Geolix.Record.Country do
  @moduledoc """
  Record for `country` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :geoname_id,
    :iso_code,
    :names
  ]

  def from(nil),  do: nil
  def from(data), do: struct(__MODULE__, data)
end
