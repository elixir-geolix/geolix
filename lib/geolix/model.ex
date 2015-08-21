defmodule Geolix.Model do
  @moduledoc """
  Behaviour for records/results.
  """

  @doc """
  Converts a dataset to a model.
  """
  @callback from(data :: any, locale :: atom) :: nil | map
end
