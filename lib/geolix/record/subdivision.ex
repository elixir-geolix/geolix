defmodule Geolix.Record.Subdivision do
  @moduledoc """
  Record for `subdivision` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :geoname_id,
    :iso_code,
    :names
  ]

  def from(nil),                     do: nil
  def from(data) when is_list(data), do: data |> Enum.map(&from/1)
  def from(data),                    do: struct(__MODULE__, data)
end
