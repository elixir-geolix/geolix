defmodule Geolix.Server do
  @moduledoc """
  Server to be called for reading a database and looking up ip information.
  """

  use GenServer

  require Logger

  @doc """
  Starts the server.
  """
  @spec start_link(any) :: GenServer.on_start
  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default, [ name: :geolix ])
  end

  def handle_call({ :lookup, ip }, _, state) do
    { :reply, Geolix.Database.lookup(ip), state }
  end

  def handle_call({ :lookup, where, ip }, _, state) do
    { :reply, Geolix.Database.lookup(where, ip), state }
  end

  def handle_call({ :set_database, which, filename }, _, state) do
    { :reply, Geolix.Database.read_database(which, filename), state }
  end
end
