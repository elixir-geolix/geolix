defmodule Geolix do
  @moduledoc """
  Geolix Application.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: Geolix.Supervisor ]
    children = [
      worker(Geolix.Server, []),
      worker(Geolix.MetadataStorage, [])
    ]

    { :ok, sup } = Supervisor.start_link(children, options)

    if Application.get_env(:geolix, :db_countries) do
      set_db_countries(Application.get_env(:geolix, :db_countries))
    end

    if Application.get_env(:geolix, :db_cities) do
      set_db_cities(Application.get_env(:geolix, :db_cities))
    end

    { :ok, sup }
  end

  @doc """
  Sets the database used to lookup `:cities` or `:countries`.
  """
  @spec set_db(atom, String.t) :: :ok | { :error, String.t }
  def set_db(which, filename) do
    if not File.regular?(filename) do
      { :error, "Given file '#{ filename }' does not exist?!" }
    else
      GenServer.call(:geolix, { :set_db, which, filename }, :infinity)
    end
  end

  @doc """
  Convenience call for `set_db/2`.
  """
  @spec set_db_cities(String.t) :: :ok | { :error, String.t }
  def set_db_cities(db_dir), do: set_db(:cities, db_dir)

  @doc """
  Convenience call for `set_db/2`.
  """
  @spec set_db_countries(String.t) :: :ok | { :error, String.t }
  def set_db_countries(db_dir), do: set_db(:countries, db_dir)

  @doc """
  Looks up the city information for the given ip.
  """
  @spec city(tuple) :: nil | map
  def city(ip), do: GenServer.call(:geolix, { :city, ip })

  @doc """
  Looks up the country information for the given ip.
  """
  @spec country(tuple) :: nil | map
  def country(ip), do: GenServer.call(:geolix, { :country, ip })

  @doc """
  Looks up the city and country information for the given ip.
  """
  @spec lookup(tuple) :: nil | map
  def lookup(ip), do: GenServer.call(:geolix, { :lookup, ip })
end
