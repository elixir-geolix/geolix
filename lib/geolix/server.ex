defmodule Geolix.Server do
  use GenServer

  require Logger

  alias Geolix.MetadataStorage

  @doc """
  Starts the server.
  """
  @spec start_link(any) :: GenServer.on_start
  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: :geolix ])
  end

  def init(_) do
    { :ok, %{ cities: nil, countries: nil }}
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

  def handle_call({ :set_db, :cities, filename }, _, state) do
    cities = Geolix.Database.read_db(filename) |> init_dataset()
    state  = %{ state | :cities => cities }

    { :reply, :ok, state }
  end
  def handle_call({ :set_db, :countries, filename }, _, state) do
    countries = Geolix.Database.read_db(filename) |> init_dataset()
    state     = %{ state | :countries => countries }

    { :reply, :ok, state }
  end
  def handle_call({ :set_db, which, _ }, _, state) do
    { :reply, { :error, "Invalid database type '#{ which }' given!" }, state }
  end

  defp init_dataset({ filename, tree, data, meta }) do
    MetadataStorage.set(filename, meta)

    %{ filename: filename, tree: tree, data: data }
  end
end
