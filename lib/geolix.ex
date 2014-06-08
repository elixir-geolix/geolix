defmodule Geolix do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    import Supervisor.Spec

    supervise([ worker(Geolix.Server, []) ], strategy: :one_for_one)
  end

  def set_db(which, db_dir) do
    if not File.dir?(db_dir) do
      { :error, "Given directory '#{db_dir}' is not a path?!" }
    end

    unless String.ends_with?(db_dir, "/") do
      db_dir = db_dir <> "/"
    end

    GenServer.call(:geolix, { :set_db, which, db_dir }, :infinity)
  end

  def set_db_cities(db_dir),    do: set_db(:cities,    db_dir)
  def set_db_countries(db_dir), do: set_db(:countries, db_dir)

  def city(ip),    do: GenServer.call(:geolix, { :city,    ip })
  def country(ip), do: GenServer.call(:geolix, { :country, ip })
  def lookup(ip),  do: GenServer.call(:geolix, { :lookup,  ip })
end
