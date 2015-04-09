defmodule Geolix.Pool do
  @moduledoc """
  Connects the Geolix interface with the underlying pool.
  """

  @doc """
  Adds a database to the pool.
  """
  @spec set_database(atom, String.t) :: :ok | { :error, String.t }
  def set_database(which, filename) do
    if not File.regular?(filename) do
      { :error, "Given file '#{ filename }' does not exist?!" }
    else
      :poolboy.transaction(
        Geolix.Server.Pool,
        &GenServer.call(&1, { :set_database, which, filename }, :infinity)
      )
    end
  end

  @doc """
  Sends a lookup request to the pool.
  """
  @spec lookup(ip :: tuple | String.t, opts  :: Keyword.t) :: nil | map
  def lookup(ip, opts \\ [ as: :struct, where: nil ])

  def lookup(ip, opts) when is_binary(ip) do
    ip = String.to_char_list(ip)

    case :inet.parse_address(ip) do
      { :ok, parsed } -> lookup(parsed, opts)
      { :error, _ }   -> nil
    end
  end

  def lookup(ip, opts) do
    :poolboy.transaction(
      Geolix.Server.Pool,
      &GenServer.call(&1, { :lookup, ip, opts })
    )
  end
end
