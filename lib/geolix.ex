defmodule Geolix do
  use Supervisor.Behaviour

  def start_link() do
    :supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    supervise([ worker(Geolix.Server, []) ], strategy: :one_for_one)
  end

  def set_db(which, db_dir) do
    if not File.dir?(db_dir) do
      { :error, "Given directory '#{db_dir}' is not a path?!" }
    end

    unless String.ends_with?(db_dir, "/") do
      db_dir = db_dir <> "/"
    end

    :gen_server.call(:geolix, { :set_db, which, db_dir }, :infinity)
  end

  def set_db_cities(db_dir),    do: set_db(:cities,    db_dir)
  def set_db_countries(db_dir), do: set_db(:countries, db_dir)

  def city(ip),    do: :gen_server.call(:geolix, { :city,    ip })
  def country(ip), do: :gen_server.call(:geolix, { :country, ip })
  def lookup(ip),  do: :gen_server.call(:geolix, { :lookup,  ip })
end
