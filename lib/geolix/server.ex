defmodule Geolix.Server do
  use GenServer

  require Logger

  alias Geolix.MetadataStorage

  @doc """
  Starts the server.
  """
  @spec start_link(any) :: GenServer.on_start
  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default, [ name: :geolix ])
  end

  def handle_call({ :lookup, ip }, _, state) do
    { :reply, Geolix.Database.lookup(ip, state), state }
  end

  def handle_call({ :lookup, where, ip }, _, state) do
    { :reply, Geolix.Database.lookup(where, ip, state), state }
  end

  def handle_call({ :set_database, which, filename }, _, state) do
    { tree, data, meta } = Geolix.Database.read_database(filename)

    MetadataStorage.set(which, meta)

    state = Map.put(state, which, %{ tree: tree, data: data })

    { :reply, :ok, state }
  end
end
