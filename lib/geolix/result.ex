defmodule Geolix.Result do
  @moduledoc """
  Converts raw lookup results into structured data.
  """

  @doc """
  Convert raw result map into struct.
  """
  @spec to_struct(type :: String.t, data :: map) :: map
  def to_struct(_type, data) do
    data
  end
end
