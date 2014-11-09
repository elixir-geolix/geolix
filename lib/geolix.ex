defmodule Geolix do
  @moduledoc """
  Geolix Application.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: Geolix.Supervisor ]
    children = [
      Geolix.Server.Pool.child_spec,

      worker(Geolix.Storage.Data, []),
      worker(Geolix.Storage.Metadata, []),
      worker(Geolix.Storage.Tree, [])
    ]

    { :ok, sup } = Supervisor.start_link(children, options)

    if Application.get_env(:geolix, :databases) do
      Enum.each(
        Application.get_env(:geolix, :databases),
        fn ({ which, filename }) -> set_database(which, filename) end
      )
    end

    { :ok, sup }
  end

  @doc """
  Adds a database to lookup data from.
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
  Looks up information for the given ip in all registered databases.
  """
  @spec lookup(tuple | String.t) :: map
  def lookup(ip) when is_binary(ip) do
    ip = String.to_char_list(ip)

    case :inet.parse_address(ip) do
      { :ok, parsed } -> lookup(parsed)
      { :error, _  }  -> nil
    end
  end
  def lookup(ip) do
    :poolboy.transaction(
      Geolix.Server.Pool,
      &GenServer.call(&1, { :lookup, ip })
    )
  end

  @doc """
  Looks up information for the given ip in the given database.
  """
  @spec lookup(atom, tuple | String.t) :: nil | map
  def lookup(where, ip) when is_binary(ip) do
    ip = String.to_char_list(ip)

    case :inet.parse_address(ip) do
      { :ok, parsed } -> lookup(where, parsed)
      { :error, _  }  -> nil
    end
  end
  def lookup(where, ip) do
    :poolboy.transaction(
      Geolix.Server.Pool,
      &GenServer.call(&1, { :lookup, where, ip })
    )
  end
end
