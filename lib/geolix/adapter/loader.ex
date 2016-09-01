defmodule Geolix.Adapter.Loader do
  @moduledoc """
  Behaviour definition for loader modules
  """

  @doc """
  Loads a given database into Geolix.
  """
  @callback load(map) :: :ok
end
