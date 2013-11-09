defmodule Geolix.Server do
  use GenServer.Behaviour

  def start_link(db_dir) do
    :gen_server.start_link({ :local, :geolix }, __MODULE__, db_dir, [])
  end

  def init(db_dir) do
    state = [ cities:    init_cities(db_dir),
              countries: init_countries(db_dir) ]

    { :ok, state }
  end

  defp init_cities(db_dir) do
    case Geolix.Database.read_cities(db_dir) do
      { :ok, tree, data, meta } -> [ tree: tree, data: data, meta: meta ]
      { :error, reason }        ->
        IO.inspect(reason)
        nil
    end
  end

  defp init_countries(db_dir) do
    case Geolix.Database.read_countries(db_dir) do
      { :ok, tree, data, meta } -> [ tree: tree, data: data, meta: meta ]
      { :error, reason }        ->
        IO.inspect(reason)
        nil
    end
  end

  def handle_call({ :lookup, ip }, _, state) do
    reply = [ city:    Geolix.Database.lookup(ip, state[:cities]),
              country: Geolix.Database.lookup(ip, state[:countries]) ]

    { :reply, reply, state }
  end
end
