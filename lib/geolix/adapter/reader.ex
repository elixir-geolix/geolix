defmodule Geolix.Adapter.Reader do
  @moduledoc """
  Behaviour definition for reader modules
  """

  @doc """
  Reads a database file and returns the data and metadata parts from it.
  """
  @callback read_database(String.t) :: { binary | :error,
                                         binary | :no_metadata }
end
