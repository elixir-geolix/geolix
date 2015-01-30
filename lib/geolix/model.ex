defmodule Geolix.Model do
  @moduledoc """
  Behaviour for records/results.
  """

  use Behaviour

  @doc """
  Converts a dataset to a model.
  """
  defcallback from(data :: any) :: nil | map
end