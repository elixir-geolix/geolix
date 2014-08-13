defmodule Geolix do
  use Application

  def start(_, _) do
    Geolix.Supervisor.start_link()

    if Application.get_env(:geolix, :db_countries) do
      set_db_countries(Application.get_env(:geolix, :db_countries))
    end

    if Application.get_env(:geolix, :db_cities) do
      set_db_cities(Application.get_env(:geolix, :db_cities))
    end

    { :ok, self() }
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
