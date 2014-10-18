defmodule Geolix.Server do
  use GenServer

  require Logger

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: :geolix ])
  end

  def init(_) do
    { :ok, %{ cities: nil, countries: nil }}
  end

  def stop() do
    GenServer.call(:geolix, :stop)
  end

  def handle_call({ :city, ip }, _, state) do
    { :reply, Geolix.Database.lookup(ip, state.cities), state }
  end

  def handle_call({ :country, ip }, _, state) do
    { :reply, Geolix.Database.lookup(ip, state.countries), state }
  end

  def handle_call({ :lookup, ip }, _, state) do
    { :reply, Geolix.Database.lookup(ip, state), state }
  end

  def handle_call({ :set_db, :cities, db_dir }, _, state) do
    cities = Geolix.Database.read_cities(db_dir) |> maybe_init_dataset()
    state  = %{ state | :cities => cities }

    { :reply, :ok, state }
  end
  def handle_call({ :set_db, :countries, db_dir }, _, state) do
    countries = Geolix.Database.read_countries(db_dir) |> maybe_init_dataset()
    state     = %{ state | :countries => countries }

    { :reply, :ok, state }
  end
  def handle_call({ :set_db, which, _ }, _, state) do
    { :reply, { :error, "Invalid database type '#{ which }' given!" }, state }
  end

  def handle_call(:stop, _from, state), do: { :stop, :normal, :ok, state }

  def terminate(_, _), do: :ok

  defp maybe_init_dataset({ :ok, tree, data, meta }) do
    %{ tree: tree, data: data, meta: meta }
  end
  defp maybe_init_dataset({ :error, reason }) do
    Logger.warn(reason)
    nil
  end
end
