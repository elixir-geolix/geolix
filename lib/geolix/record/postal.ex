defmodule Geolix.Record.Postal do
  @moduledoc """
  Record for `postal` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :code
  ]

  def from(nil, _), do: nil
  def from(data, _), do: struct(__MODULE__, data)
end
