defmodule Geolix.Adapter.MMDB2.Names do
  @moduledoc """
  Provides usable GenServer names.
  """

  @doc """
  Returns GenServer names for storage processes.
  """
  @spec storage(atom) :: atom
  def storage(:data), do: :geolix_mmdb2_storage_data
  def storage(:metadata), do: :geolix_mmdb2_storage_metadata
  def storage(:tree), do: :geolix_mmdb2_storage_tree
end
