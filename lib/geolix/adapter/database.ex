defmodule Geolix.Adapter.Database do
  @moduledoc """
  Behaviour definition for database modules
  """

  @doc """
  Looks up IP information.
  """
  @callback lookup(ip :: tuple, opts :: Keyword.t) :: map
end
