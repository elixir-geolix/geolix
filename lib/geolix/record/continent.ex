defmodule Geolix.Record.Continent do
  @moduledoc """
  Record for `continent` information.
  """

  @behaviour Geolix.Model

  defstruct [
    :code,
    :geoname_id,
    :names,
  ]

  def from(nil), do: nil
  def from(data) do
    %__MODULE__{
      code:       data[:code],
      geoname_id: data[:geoname_id],
      names:      data[:names]
    }
  end
end
