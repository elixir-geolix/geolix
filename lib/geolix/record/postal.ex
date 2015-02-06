defmodule Geolix.Record.Postal do
  @moduledoc """
  Record for `postal` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :code
  ]

  def from(nil),  do: nil
  def from(data), do: struct(__MODULE__, data)
end
