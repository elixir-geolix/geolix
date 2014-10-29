defmodule Geolix.Server.Worker do
  @moduledoc """
  Worker module reading a database and looking up ip information.
  """

  use GenServer

  require Logger

  @behaviour :poolboy_worker

  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default)
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
