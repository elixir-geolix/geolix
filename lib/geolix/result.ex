defmodule Geolix.Result do
  @moduledoc """
  Converts raw lookup results into structured data.
  """

  alias Geolix.Result

  @mapping [
    { "GeoIP2-City",           Result.City },
    { "GeoIP2-Precision-City", Result.City },
    { "GeoIP2-Country",        Result.Country },
    { "GeoLite2-City",         Result.City },
    { "GeoLite2-Country",      Result.Country }
  ]

  @mapping_flat [
    { "GeoIP2-Anonymous-IP",    Result.AnonymousIP },
    { "GeoIP2-Connection-Type", Result.ConnectionType },
    { "GeoIP2-Domain",          Result.Domain },
    { "GeoIP2-ISP",             Result.ISP },
    { "GeoIP2-Precision-ISP",   Result.ISP }
  ]

  @doc """
  Convert raw result map into struct.
  """
  @spec to_struct(type :: String.t, data :: map | nil, locale :: atom) :: map
  def to_struct(_type, nil, _), do: nil

  for { type, model } <- @mapping do
    def to_struct(unquote(type), data, locale) do
      structify(unquote(model), data, locale)
    end
  end

  for { type, model } <- @mapping_flat do
    def to_struct(unquote(type), data, locale) do
      structify_flat(unquote(model), data, locale)
    end
  end

  def to_struct(_type, data, _), do: data

  @doc false
  @spec structify(model :: atom, data :: map, locale :: atom) :: map
  def structify(model, data, locale) do
    result = model.from(data, locale)
    traits = result.traits |> Map.put(:ip_address, data[:ip_address])

    result |> Map.put(:traits, traits)
  end

  @doc false
  @spec structify_flat(model :: atom, data :: map, locale :: atom) :: map
  def structify_flat(model, data, locale), do: model.from(data, locale)
end
