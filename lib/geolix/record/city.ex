defmodule Geolix.Record.City do
  @moduledoc """
  Record for `city` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :geoname_id,
    :names,
  ]

  def from(nil),  do: nil
  def from(data), do: struct(__MODULE__, data)
end
