defmodule Geolix.Server do
  use GenServer.Behaviour

  def start_link(data_path) do
    :gen_server.start_link({ :local, :geolix }, __MODULE__, data_path, [])
  end

  def init(data_path) do
    IO.inspect(data_path)
    { :ok, [] }
  end
end
