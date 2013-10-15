defmodule Geolix.Server do
  use GenServer.Behaviour

  def start_link(db_dir) do
    :gen_server.start_link({ :local, :geolix }, __MODULE__, db_dir, [])
  end

  def init(db_dir) do
    case Geolix.Database.read_cities(db_dir) do
      { :error, reason } -> IO.inspect(reason)
      { metadata, _} -> IO.inspect(metadata)
    end

    case Geolix.Database.read_countries(db_dir) do
      { :error, reason } -> IO.inspect(reason)
      { metadata, _ } -> IO.inspect(metadata)
    end

    { :ok, [] }
  end
end
