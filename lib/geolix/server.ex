defmodule Geolix.Server do
  use GenServer.Behaviour

  def start_link(db_dir) do
    :gen_server.start_link({ :local, :geolix }, __MODULE__, db_dir, [])
  end

  def init(db_dir) do
    Geolix.Database.read(db_dir)
  end
end
