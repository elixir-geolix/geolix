defmodule Geolix do
  @moduledoc """
  Geolix Application.
  """

  use Application

  alias Geolix.Database.Loader
  alias Geolix.Server.Pool


  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: Geolix.Supervisor ]
    children = [
      Pool.child_spec,
      supervisor(Geolix.Database.Supervisor, [])
    ]

    Supervisor.start_link(children, options)
  end

  @doc """
  Adds a database to lookup data from.
  """
  @spec set_database(atom, String.t) :: :ok | { :error, String.t }
  def set_database(which, filename) do
    if not File.regular?(filename) do
      { :error, "Given file '#{ filename }' does not exist?!" }
    else
      GenServer.call(Loader, { :set_database, which, filename }, :infinity)
    end
  end

  @doc """
  Looks up IP information.
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
    :poolboy.transaction(Pool, &GenServer.call(&1, { :lookup, ip, opts }))
  end
end
