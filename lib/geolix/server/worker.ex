defmodule Geolix.Server.Worker do
  @moduledoc """
  Worker module reading a database and looking up IP information.
  """

  alias Geolix.Adapter.MMDB2

  use GenServer

  @behaviour :poolboy_worker

  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default)
  end

  def handle_call({ :lookup, ip, opts }, _, state) do
    { :reply, MMDB2.lookup(ip, opts), state }
  end
end
