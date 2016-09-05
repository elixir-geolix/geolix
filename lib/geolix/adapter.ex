defmodule Geolix.Adapter do
  @moduledoc """
  Adapter behaviour module.
  """


  @doc """
  Loads a given database into Geolix.
  """
  @callback load_database(map) :: :ok

  @doc """
  Looks up IP information.
  """
  @callback lookup(ip :: tuple, opts :: Keyword.t) :: map
end
