defmodule Geolix do
  @moduledoc """
  Geolix Application.
  """

  use Application

  alias Geolix.Database.Loader
  alias Geolix.Server.Pool

  @type database_file :: String.t | { :system, String.t }

  @lookup_default_opts [
    as:     :struct,
    locale: :en,
    where:  nil
  ]


  def start(_type, _args), do: Geolix.Supervisor.start_link()


  @doc """
  Adds a database to lookup data from.
  """
  @spec set_database(atom, database_file) :: :ok | { :error, String.t }
  def set_database(which, filename) do
    GenServer.call(Loader, { :set_database, which, filename }, :infinity)
  end

  @doc """
  Loads a database according to its specification.
  """
  @spec load_database(map) :: :ok | { :error, String.t }
  def load_database(database) do
    GenServer.call(Loader, { :load_database, database }, :infinity)
  end

  @doc """
  Looks up IP information.
  """
  @spec lookup(ip :: tuple | String.t, opts  :: Keyword.t) :: nil | map
  def lookup(ip, opts \\ [])
  def lookup(ip, opts) when is_binary(ip) do
    ip = String.to_char_list(ip)

    case :inet.parse_address(ip) do
      { :ok, parsed } -> lookup(parsed, opts)
      { :error, _ }   -> nil
    end
  end

  def lookup(ip, opts) do
    :poolboy.transaction(Pool, &GenServer.call(&1, {
      :lookup,
      ip,
      Keyword.merge(@lookup_default_opts, opts)
    }))
  end
end
