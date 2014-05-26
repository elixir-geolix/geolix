defmodule Geolix.Server do
  use GenServer.Behaviour

  def start_link(db_dir) do
    :gen_server.start_link({ :local, :geolix }, __MODULE__, db_dir, [])
  end

  def init(db_dir) do
    { :ok, %{ cities:    init_cities(db_dir),
              countries: init_countries(db_dir) } }
  end

  defp init_cities(db_dir) do
    Geolix.Database.read_cities(db_dir) |> maybe_init_dataset()
  end

  defp init_countries(db_dir) do
    Geolix.Database.read_countries(db_dir) |> maybe_init_dataset()
  end

  defp maybe_init_dataset({ :ok, tree, data, meta }) do
    %{ tree: tree, data: data, meta: meta }
  end
  defp maybe_init_dataset({ :error, reason }) do
    IO.inspect(reason)
    nil
  end

  def handle_call({ :city, ip }, _, state) do
    { :reply, Geolix.Database.lookup(ip, state[:cities]), state }
  end

  def handle_call({ :country, ip }, _, state) do
    { :reply, Geolix.Database.lookup(ip, state[:countries]), state }
  end

  def handle_call({ :lookup, ip }, _, state) do
    { :reply, Geolix.Database.lookup(ip, state), state }
  end
end
