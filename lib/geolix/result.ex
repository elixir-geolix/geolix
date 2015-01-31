defmodule Geolix.Result do
  @moduledoc """
  Converts raw lookup results into structured data.
  """

  alias Geolix.Result

  @mapping [
    { "GeoIP2-City",      Result.City },
    { "GeoIP2-Country",   Result.Country },
    { "GeoLite2-City",    Result.City },
    { "GeoLite2-Country", Result.Country }
  ]

  @mapping_flat [
    { "GeoIP2-Anonymous-IP",    Result.AnonymousIP },
    { "GeoIP2-Connection-Type", Result.ConnectionType },
    { "GeoIP2-Domain",          Result.Domain },
    { "GeoIP2-ISP",             Result.ISP }
  ]

  @doc """
  Convert raw result map into struct.
  """
  @spec to_struct(type :: String.t, data :: map) :: map
  def to_struct(_type, nil), do: nil

  for { type, model } <- @mapping do
    def to_struct(unquote(type), data) do
      structify(unquote(model), data)
    end
  end

  for { type, model } <- @mapping_flat do
    def to_struct(unquote(type), data) do
      structify_flat(unquote(model), data)
    end
  end

  def to_struct(_type, data), do: data

  @doc false
  @spec structify(model :: atom, data :: map) :: map
  def structify(model, data) do
    result = model.from(data)
    traits = result.traits |> Map.put(:ip_address, data[:ip_address])

    result |> Map.put(:traits, traits)
  end

  @doc false
  @spec structify_flat(model :: atom, data :: map) :: map
  def structify_flat(model, data), do: model.from(data)
end
